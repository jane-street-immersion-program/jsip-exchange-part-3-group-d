(** Scaffolding for bot tests. *)

open! Core
open! Async
open Jsip_types
open Jsip_fundamental
open Jsip_bot_runtime
open! Jsip_bots

let aapl = Symbol.of_string "AAPL"
let alice = Participant.of_string "Alice"

let oracle_config ~initial_price_cents =
  Symbol.Map.of_alist_exn
    [ ( aapl
      , { Fundamental_oracle.Config.initial_price_cents
        ; volatility_cents_per_sec = 0.0
        ; mean_reversion_strength = 0.0
        ; tick_interval = Time_ns.Span.of_sec 1.0
        } )
    ]
;;

(* Build a runtime around a bot module with a mock submit/cancel that records
   what the bot does. *)
let make_recording_bot
  (type cfg)
  (bot_module : (module Bot_runtime.Bot with type Config.t = cfg))
  (config : cfg)
  ?(initial_price_cents = 15000)
  ()
  =
  let submitted = ref [] in
  let cancelled = ref [] in
  let submit request =
    submitted := request :: !submitted;
    return (Ok ())
  in
  let cancel order_id =
    cancelled := order_id :: !cancelled;
    return (Ok ())
  in
  let oracle =
    Fundamental_oracle.create (oracle_config ~initial_price_cents) ~seed:42
  in
  let bot =
    Bot_runtime.create
      bot_module
      config
      ~participant:alice
      ~oracle
      ~rng:(Splittable_random.of_int 7)
      ~submit
      ~cancel
      ~tick_interval:(Time_ns.Span.of_sec 1.0)
  in
  bot, submitted, cancelled
;;

let print_submitted (submitted : Order.Request.t list ref) =
  let recent = List.rev !submitted in
  List.iter recent ~f:(fun req ->
    printf
      !"%{Side} %{Symbol} %d@%{Price#dollar} %{Time_in_force}\n"
      req.side
      req.symbol
      (Size.to_int req.size)
      req.price
      req.time_in_force)
;;

(* Smoke test: drive the do-nothing reference bot through one event so the
   runtest target exercises the helpers above. Replace or extend with
   bot-specific tests as concrete strategies are added to [Jsip_bots]. *)
module Inert_bot = struct
  module Config = struct
    type t = unit
  end

  let name = "inert"
  let on_start () _ctx = return ()
  let on_tick () _ctx = return ()
  let on_event () _ctx _event = return ()
end

(* Print one line per submitted order (client order id, side, price, size,
   time-in-force) followed by the cancelled ids in submission order, so a
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

(* The cancel storm's defining behavior: every cycle submits a passive order
   under a brand-new client order id and immediately cancels that same id.
   Driving two ticks of three cycles should produce ids 1..6, each cancelled,
   with the fundamental-relative pricing ($150 fundamental, $5 offset -> buys
   at $145, sells at $155). The fresh, monotonic ids are the property that
   keeps the storm from being blocked by duplicate detection; the sides come
   from the seeded [Context.random]. *)
let%expect_test "cancel storm submits then cancels a fresh id each cycle" =
  let config =
    Cancel_storm.Config.create
      ~symbols:[ aapl ]
      ~cycles_per_tick:3
      ~order_size:10
      ~price_offset_cents:500
  in
  let bot, submitted, cancelled =
    make_recording_bot (module Cancel_storm) config ()
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

let%expect_test "make_recording_bot wires up a runnable bot" =
  let bot, submitted, _cancelled =
    make_recording_bot (module Inert_bot) () ()
  in
  let%bind () =
    Bot_runtime.feed_event
      bot
      (Order_accept
         { order_id = Order_id.For_testing.of_int 1
         ; participant = alice
         ; request =
             { client_order_id = Client_order_id.of_int 1
             ; symbol = aapl
             ; side = Buy
             ; price = Price.of_int_cents 15000
             ; size = Size.of_int 10
             ; time_in_force = Day
             }
         })
  in
  print_submitted submitted;
  [%expect {| |}];
  return ()
;;
