(* The Cancel_storm bot. The "what and why" lives in the .mli; the comments
   here flag only the non-obvious bits. *)

open! Core
open! Async
open Jsip_types
module Context = Jsip_bot_runtime.Bot_runtime.Context

module Config = struct
  type t =
    { symbols : Symbol.t list (* stocks to churn on *)
    ; cycles_per_tick : int (* submit+cancel pairs run per tick *)
    ; order_size : int (* shares on each order *)
    ; price_offset_cents : int (* distance from the fundamental to rest at *)
    ; mutable next_client_order_id : int
    (* Climbs across ticks so every order gets a brand-new id; see
       [fresh_client_order_id]. *)
    }
  [@@deriving sexp_of]

  (* Raise on nonsensical config: a scenario with e.g. zero cycles is a
     programming mistake worth catching immediately. *)
  let create ~symbols ~cycles_per_tick ~order_size ~price_offset_cents =
    if List.is_empty symbols
    then raise_s [%message "Cancel_storm needs at least one symbol"];
    if cycles_per_tick <= 0
    then
      raise_s
        [%message
          "Cancel_storm cycles_per_tick must be positive"
            (cycles_per_tick : int)];
    if order_size <= 0
    then
      raise_s
        [%message
          "Cancel_storm order_size must be positive" (order_size : int)];
    (* Ids start at 1 and only climb; the exchange scopes them per
       participant, so the starting value is irrelevant as long as each is
       used exactly once. *)
    { symbols
    ; cycles_per_tick
    ; order_size
    ; price_offset_cents
    ; next_client_order_id = 1
    }
  ;;
end

let name = "cancel-storm"

(* Hand out the next never-before-used id, then bump the counter. This is the
   crux of the bot: the matching engine permanently records every accepted id
   per participant and rejects repeats as duplicates (cancelling does NOT
   free an id), so reusing one would bounce every submit after the first and
   stall the storm. *)
let fresh_client_order_id (config : Config.t) =
  let id = config.next_client_order_id in
  config.next_client_order_id <- id + 1;
  Client_order_id.of_int id
;;

(* Round-robin across the configured symbols; with a single symbol this
   always returns that symbol. *)
let pick_symbol (config : Config.t) client_order_id =
  let idx =
    Client_order_id.to_int client_order_id % List.length config.symbols
  in
  List.nth_exn config.symbols idx
;;

let run_cycle (config : Config.t) context =
  let client_order_id = fresh_client_order_id config in
  let symbol = pick_symbol config client_order_id in
  (* Seeded random source so a fixed-seed scenario replays identically. *)
  let side : Side.t =
    match Splittable_random.int (Context.random context) ~lo:0 ~hi:1 with
    | 0 -> Buy
    | _ -> Sell
  in
  (* Price away from the fundamental so the order rests instead of trading —
     it needs to rest so there is something to cancel. *)
  let fundamental = Context.fundamental context symbol in
  let offset = Price.of_int_cents config.price_offset_cents in
  let price =
    match side with
    | Buy -> Price.(fundamental - offset)
    | Sell -> Price.(fundamental + offset)
  in
  let request : Order.Request.t =
    { client_order_id
    ; symbol
    ; side
    ; price
    ; size = Size.of_int config.order_size
    ; time_in_force = Day
    }
  in
  (* Await the submit before cancelling: both share the exchange's single
     ordered request queue, so this guarantees the engine sees the create
     before the cancel (rather than "order not found"). The result here is
     only the RPC's success/failure; an engine-level reject arrives later as
     an event. *)
  let%bind submit_result = Context.submit context request in
  (match submit_result with
   | Ok () -> ()
   | Error error ->
     [%log.error
       "cancel_storm: submit failed"
         (request : Order.Request.t)
         (error : Error.t)]);
  let%map cancel_result = Context.cancel context client_order_id in
  match cancel_result with
  | Ok () -> ()
  | Error error ->
    [%log.error
      "cancel_storm: cancel failed"
        (client_order_id : Client_order_id.t)
        (error : Error.t)]
;;

let on_start (_config : Config.t) _context = return ()

(* Run [cycles_per_tick] cycles sequentially each tick; many per tick is what
   turns a trickle into a storm. *)
let on_tick (config : Config.t) context =
  Deferred.List.iter
    ~how:`Sequential
    (List.init config.cycles_per_tick ~f:Fn.id)
    ~f:(fun (_ : int) -> run_cycle config context)
;;

let on_event (_config : Config.t) _context (_event : Exchange_event.t) =
  return ()
;;
