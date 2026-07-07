(** Unit tests for the [Slow_consumer] pathological bot.

    The bot's misbehavior lives entirely in [on_event], which sleeps for
    [Config.read_delay] before returning. The scenario runner drains each
    subscribed feed with [Pipe.iter ~f:(Bot_runtime.feed_event bot)], this
    works because [Pipe.iter] is *sequential*: it does not pull the next
    value off the pipe until the [Deferred.t] returned by the previous
    [on_event] resolves. So a [read_delay] sleep caps the drain at one event
    per [read_delay].

    These tests check for the following behavior:

    - With a nonzero [read_delay], the reader consumes exactly one event and
      then stalls, leaving the buffer backed up
    - With [read_delay = 0] (a well-behaved reader, used as a control), the
      same loop drains the buffer completely. *)

open! Core
open! Async
open Jsip_types
open Jsip_fundamental
open Jsip_bot_runtime
open Jsip_bots

let aapl = Symbol.of_string "AAPL"
let alice = Participant.of_string "Alice"

(* A market-data event for the slow consumer to read off the pipe. The bot
   ignores the event's contents (it only sleeps), so [price] and [size] are
   filler *)
let trade_report =
  Exchange_event.Trade_report
    { symbol = aapl; price = Price.of_int_cents 0; size = Size.of_int 0 }
;;

(* A [Slow_consumer] bot with the given read delay. [on_event] ignores its
   context, so the oracle, rng, submit/cancel, and tick interval are never
   consulted — only [read_delay] impacts behavior. *)
let make_slow_consumer ~read_delay =
  let oracle =
    Fundamental_oracle.create
      (Symbol.Map.of_alist_exn
         [ ( aapl
           , { Fundamental_oracle.Config.initial_price_cents = 0
             ; volatility_cents_per_sec = 0.0
             ; mean_reversion_strength = 0.0
             ; tick_interval = Time_ns.Span.zero
             } )
         ])
      ~seed:0
  in
  let inert_dispatch _ = return (Ok ()) in
  Bot_runtime.create
    (module Slow_consumer)
    { Slow_consumer.Config.read_delay }
    ~participant:alice
    ~oracle
    ~rng:(Splittable_random.of_int 0)
    ~submit:inert_dispatch
    ~cancel:inert_dispatch
    ~tick_interval:Time_ns.Span.zero
;;

(* Stand in for the exchange-side buffer: a pipe the exchange fills without
   pushback , drained by the runner's [Pipe.iter ~f:(feed_event bot)] loop. *)
let fill_buffer n =
  let reader, writer = Pipe.create () in
  let rec fill_buffer_helper num =
    match num = 0 with
    | true -> ()
    | false ->
      Pipe.write_without_pushback writer trade_report;
      fill_buffer_helper (num - 1)
  in
  fill_buffer_helper n;
  reader, writer
;;

let%expect_test "a slow reader stalls with the exchange-side buffer full" =
  (* A [read_delay] far longer than the test: once the reader enters it, it
     will not read again for the duration of the test. *)
  let bot = make_slow_consumer ~read_delay:(Time_ns.Span.of_sec 100.0) in
  let reader, _writer = fill_buffer 5 in
  printf "buffered before draining: %d\n" (Pipe.length reader);
  don't_wait_for (Pipe.iter reader ~f:(Bot_runtime.feed_event bot));
  let%bind () = Scheduler.yield_until_no_jobs_remain () in
  printf "buffered after the reader stalls: %d\n" (Pipe.length reader);
  (match Pipe.read_now' reader with
   | `Ok q ->
     printf "still queued for the slow reader: %d\n" (Queue.length q)
   | `Eof -> printf "buffer closed\n"
   | `Nothing_available -> printf "buffer empty\n");
  [%expect
    {|
    buffered before draining: 5
    buffered after the reader stalls: 4
    still queued for the slow reader: 4
    |}];
  return ()
;;

let%expect_test "a well-behaved reader (read_delay = 0) drains the buffer" =
  let bot = make_slow_consumer ~read_delay:Time_ns.Span.zero in
  let reader, writer = fill_buffer 5 in
  (* Closing the writer lets [Pipe.iter] terminate once the buffer is empty,
     so the test can wait for the drain to finish instead of guessing a
     duration. With no read delay the reader keeps up and empties it. *)
  Pipe.close writer;
  printf "buffered before draining: %d\n" (Pipe.length reader);
  let%bind () = Pipe.iter reader ~f:(Bot_runtime.feed_event bot) in
  printf "buffered after draining: %d\n" (Pipe.length reader);
  [%expect
    {|
    buffered before draining: 5
    buffered after draining: 0
    |}];
  return ()
;;
