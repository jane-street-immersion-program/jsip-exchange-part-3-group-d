(** Tests for {!Jsip_bots.Book_filler}.

    The book filler's job is to pile resting Day orders that never fill.
    These tests drive a single [on_tick] against a recording harness (no real
    exchange) and assert the *structural* properties of what it submits — the
    order count, that everything rests, that nothing is priced to cross, and
    that ids are fresh — rather than the exact prices, which are RNG-derived
    and would make the test a tautology. *)

open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime
open! Jsip_bots

let aapl = Symbol.of_string "AAPL"

(* The fundamental the harness pins for [aapl] *)
let fair_cents = 15000

(* A fresh config per run. [next_client_id] is mutable, so building a new
   record each time allows values to stay comparable *)
let make_config () : Book_filler.Config.t =
  { symbols = [ aapl ]
  ; orders_per_tick = 20
  ; order_size = 100
  ; min_offset = 100
  ; max_random_offset = 500
  ; next_client_id = 1
  }
;;

(* Drive exactly one [on_tick] and return the orders it submitted, oldest
   first. The harness fixes the participant, the RNG seed (7), and the
   oracle, so this behavior is fully deterministic. *)
let submit_one_tick config =
  let bot, submitted, _cancelled =
    Test_bots.make_recording_bot
      (module Book_filler)
      config
      ~initial_price_cents:fair_cents
      ()
  in
  let context = Bot_runtime.For_testing.context_of bot in
  let%map () = Book_filler.on_tick config context in
  List.rev !submitted
;;

let%expect_test "one tick submits the expected pile of non-marketable \
                 resting orders"
  =
  let config = make_config () in
  let%bind orders = submit_one_tick config in
  let count = List.length orders in
  let buys, sells =
    List.partition_tf orders ~f:(fun r -> Side.equal r.side Buy)
  in
  let all_day =
    List.for_all orders ~f:(fun r -> Time_in_force.equal r.time_in_force Day)
  in
  (* A resting order only fills if it crosses the touch. The filler prices
     every buy at most [min_offset] below fair and every sell at least
     [min_offset] above fair *)
  let none_would_cross =
    List.for_all buys ~f:(fun r ->
      Price.to_int_cents r.price <= fair_cents - config.min_offset)
    && List.for_all sells ~f:(fun r ->
      Price.to_int_cents r.price >= fair_cents + config.min_offset)
  in
  (* The random jitter is bounded: distance from fair is [min_offset] plus a
     draw in [[0, max_random_offset]], so every order lands between
     [min_offset] and [min_offset + max_random_offset] cents out. Guards
     against an off-by-one error *)
  let within_depth_band =
    let max_off = config.min_offset + config.max_random_offset in
    List.for_all orders ~f:(fun r ->
      let distance = abs (Price.to_int_cents r.price - fair_cents) in
      distance >= config.min_offset && distance <= max_off)
  in
  let sizes_in_range =
    List.for_all orders ~f:(fun r ->
      let size = Size.to_int r.size in
      size >= 1 && size <= config.order_size)
  in
  (* Every order must carry a fresh id; comparing the id-set size to the
     order count is an independent check that all [count] ids are distinct. *)
  let ids = List.map orders ~f:(fun r -> r.client_order_id) in
  let unique_ids = Set.length (Client_order_id.Set.of_list ids) in
  printf "orders submitted: %d\n" count;
  printf
    "buys + sells account for all: %b\n"
    (List.length buys + List.length sells = count);
  printf "all time_in_force = Day: %b\n" all_day;
  printf "none priced to cross the touch: %b\n" none_would_cross;
  printf "all within the depth band: %b\n" within_depth_band;
  printf "all sizes in [1, order_size]: %b\n" sizes_in_range;
  printf "distinct client_order_ids: %d\n" unique_ids;
  [%expect
    {|
    orders submitted: 20
    buys + sells account for all: true
    all time_in_force = Day: true
    none priced to cross the touch: true
    all within the depth band: true
    all sizes in [1, order_size]: true
    distinct client_order_ids: 20
    |}];
  return ()
;;

let%expect_test "runs are reproducible: same seed submits identical orders" =
  (* Every stochastic choice flows through [Context.random], which the
     harness seeds identically on each build. Two independent single-tick
     runs must submit byte-for-byte identical requests. If someone
     reintroduced a [Random.self_init] or a fresh un-seeded state, this flips
     to [false]. *)
  let%bind first = submit_one_tick (make_config ()) in
  let%bind second = submit_one_tick (make_config ()) in
  let identical =
    Sexp.equal
      ([%sexp_of: Order.Request.t list] first)
      ([%sexp_of: Order.Request.t list] second)
  in
  printf "identical across identical seed: %b\n" identical;
  [%expect {| identical across identical seed: true |}];
  return ()
;;

let%expect_test "a fill against the bot is ignored: no submit, no cancel" =
  let config = make_config () in
  let bot, submitted, cancelled =
    Test_bots.make_recording_bot
      (module Book_filler)
      config
      ~initial_price_cents:fair_cents
      ()
  in
  (* A fill in which one of the bot's own resting orders (the [resting_*]
     side, owned by the harness participant "Alice") trades against a taker.
     The book filler is not reactive: its orders exist to sit on the book, so
     a fill is not a signal to do anything. *)
  let fill : Exchange_event.t =
    Fill
      { fill_id = 1
      ; symbol = aapl
      ; price = Price.of_int_cents fair_cents
      ; size = Size.of_int 10
      ; aggressor_order_id = Order_id.For_testing.of_int 1
      ; aggressor_client_order_id = Client_order_id.of_int 1
      ; aggressor_participant = Participant.of_string "Taker"
      ; aggressor_side = Buy
      ; resting_order_id = Order_id.For_testing.of_int 2
      ; resting_client_order_id = Client_order_id.of_int 1
      ; resting_participant = Participant.of_string "Alice"
      }
  in
  let%bind () = Bot_runtime.feed_event bot fill in
  (* [on_event] is a no-op, so the fill leaves both logs empty. These counts
     being zero is the whole assertion: if someone later makes the filler
     react to fills (e.g. replacing the filled order), the submit or cancel
     count moves off zero and this test catches the behavior change. *)
  printf "submitted after fill: %d\n" (List.length !submitted);
  printf "cancelled after fill: %d\n" (List.length !cancelled);
  [%expect {|
    submitted after fill: 0
    cancelled after fill: 0
    |}];
  return ()
;;
