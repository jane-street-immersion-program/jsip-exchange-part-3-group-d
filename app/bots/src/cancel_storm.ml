open! Core
open! Async
open Jsip_types
module Context = Jsip_bot_runtime.Bot_runtime.Context

module Config = struct
  type t =
    { symbols : Symbol.t list
    ; cycles_per_tick : int
    ; order_size : int
    ; price_offset_cents : int
    ; mutable next_client_order_id : int
    }
  [@@deriving sexp_of]

  (* Client order ids start here and only ever increase. The exact value is
     irrelevant — the matching engine scopes ids per participant — so long as
     each cycle sees a fresh one. *)
  let first_client_order_id = 1

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
    { symbols
    ; cycles_per_tick
    ; order_size
    ; price_offset_cents
    ; next_client_order_id = first_client_order_id
    }
  ;;
end

let name = "cancel-storm"

(* Hand out the next never-before-used client order id, advancing the
   counter. This is the crux of the bot: the matching engine permanently
   records every accepted [(participant, client_order_id)] to reject
   duplicates, so a stale id would get every submit after the first rejected
   and the storm would stall. *)
let fresh_client_order_id (config : Config.t) =
  let id = config.next_client_order_id in
  config.next_client_order_id <- id + 1;
  Client_order_id.of_int id
;;

(* Round-robin across the configured symbols keyed off the (ever-increasing)
   client order id, so a multi-symbol storm spreads evenly and
   deterministically. *)
let pick_symbol (config : Config.t) client_order_id =
  let idx =
    Client_order_id.to_int client_order_id % List.length config.symbols
  in
  List.nth_exn config.symbols idx
;;

(* One submit/cancel cycle: rest a passive order priced away from the
   fundamental, then immediately cancel it. Submit is awaited before cancel
   so that — both actions sharing the exchange's single ordered request queue
   — the engine accepts the order before it sees the matching cancel. *)
let run_cycle (config : Config.t) context =
  let client_order_id = fresh_client_order_id config in
  let symbol = pick_symbol config client_order_id in
  let side : Side.t =
    match Splittable_random.int (Context.random context) ~lo:0 ~hi:1 with
    | 0 -> Buy
    | _ -> Sell
  in
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

let on_tick (config : Config.t) context =
  Deferred.List.iter
    ~how:`Sequential
    (List.init config.cycles_per_tick ~f:Fn.id)
    ~f:(fun (_ : int) -> run_cycle config context)
;;

let on_event (_config : Config.t) _context (_event : Exchange_event.t) =
  return ()
;;
