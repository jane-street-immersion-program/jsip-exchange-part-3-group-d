(** Tests for {!Jsip_bots.Cancel_storm}.

    The cancel storm's defining behavior: every cycle submits a passive order
    under a brand-new client order id and immediately cancels that same id.
    Driving two ticks of three cycles should produce ids 1..6, each
    cancelled, with fundamental-relative pricing ($150 fundamental, $5 offset
    -> buys at $145, sells at $155). The fresh, monotonic ids are the
    property that keeps the storm from being blocked by duplicate detection;
    the sides come from the seeded [Context.random]. Lives in its own file
    (rather than [test_bots]) so it does not conflict with other bots' tests. *)

open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime
open! Jsip_bots

let aapl = Symbol.of_string "AAPL"

(* Print one line per submitted order (client order id, side, price, size,
   time-in-force) followed by the cancelled ids in submission order, so the
   test can eyeball both that every id is fresh and that each submit is
   paired with a cancel of the same id. *)
let print_submits_and_cancels
  (submitted : Order.Request.t list ref)
  (cancelled : Client_order_id.t list ref)
  =
  List.iter (List.rev !submitted) ~f:(fun (req : Order.Request.t) ->
    printf
      !"submit coid=%d %{Side} %{Price#dollar} size=%d %{Time_in_force}\n"
      (Client_order_id.to_int req.client_order_id)
      req.side
      req.price
      (Size.to_int req.size)
      req.time_in_force);
  printf
    "cancels: %s\n"
    (List.rev_map !cancelled ~f:(fun id ->
       Int.to_string (Client_order_id.to_int id))
     |> String.concat ~sep:",")
;;

let%expect_test "cancel storm submits then cancels a fresh id each cycle" =
  let config =
    Cancel_storm.Config.create
      ~symbols:[ aapl ]
      ~cycles_per_tick:3
      ~order_size:10
      ~price_offset_cents:500
  in
  let bot, submitted, cancelled =
    Test_bots.make_recording_bot (module Cancel_storm) config ()
  in
  let context = Bot_runtime.For_testing.context_of bot in
  let%bind () = Cancel_storm.on_tick config context in
  let%bind () = Cancel_storm.on_tick config context in
  print_submits_and_cancels submitted cancelled;
  [%expect
    {|
    submit coid=1 SELL $155.00 size=10 DAY
    submit coid=2 SELL $155.00 size=10 DAY
    submit coid=3 BUY $145.00 size=10 DAY
    submit coid=4 BUY $145.00 size=10 DAY
    submit coid=5 SELL $155.00 size=10 DAY
    submit coid=6 BUY $145.00 size=10 DAY
    cancels: 1,2,3,4,5,6
    |}];
  return ()
;;
