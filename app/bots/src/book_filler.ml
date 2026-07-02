open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime

module Config = struct
  type t =
    { symbols : Symbol.t list
    ; orders_per_tick : int
    ; order_size : int
    ; min_offset : int
    ; max_random_offset : int
    ; mutable next_client_id : int
    }
  [@@deriving sexp_of]
end

let name = "book_filler"

let on_start (_config : Config.t) (_context : Bot_runtime.Context.t)
  : unit Deferred.t
  =
  (** Book filler has no ladder / window state to prime*)
  Deferred.unit
;;

let on_tick (config : Config.t) (context : Bot_runtime.Context.t)
  : unit Deferred.t
  =
  (* On each tick, submit [config.orders_per_tick] fresh
   resting Day orders across [config.symbols], priced so they rest rather
   than match *)
  let rng = Bot_runtime.Context.random context in
  let submit_order ~symbol ~side ~price ~size =
    let request =
      ({ client_order_id = Client_order_id.of_int config.next_client_id
       ; symbol
       ; side
       ; price
       ; size
       ; time_in_force = Day
       }
       : Order.Request.t)
    in
    config.next_client_id <- config.next_client_id + 1;
    match%map Bot_runtime.Context.submit context request with
    | Ok () -> ()
    | Error error ->
      [%log.error "book_filler: submit failed" (error : Error.t)]
  in
  Deferred.List.iter
    ~how:(`Max_concurrent_jobs 50)
    config.symbols
    ~f:(fun symbol ->
      let fair_price = Bot_runtime.Context.fundamental context symbol in
      Deferred.List.iter
        ~how:(`Max_concurrent_jobs 50)
        (List.init config.orders_per_tick ~f:Fn.id)
        ~f:(fun (_ : int) ->
          let side : Side.t =
            if Splittable_random.int rng ~lo:0 ~hi:1 = 0 then Buy else Sell
          in
          let price_difference =
            Splittable_random.int rng ~lo:0 ~hi:config.max_random_offset
          in
          let size =
            Size.of_int
              (Splittable_random.int rng ~lo:1 ~hi:config.order_size)
          in
          let offset =
            Price.of_int_cents (price_difference + config.min_offset)
          in
          let price_operator =
            match side with 
            | Buy -> Price.(-)
            | Sell -> Price.(+)
          in
          submit_order ~symbol ~side ~price:(price_operator fair_price offset) ~size))
;;

(* Called for every session-feed / market-data event involving this bot. The
   book filler doesn't react to fills or acceptances (its orders are meant to
   rest, not trade), so it ignores events. Handle specific [Exchange_event.t]
   variants here if you want it to respond to, say, an [Order_reject]. *)
(** on order accept increase next_client_order_id *)
let on_event
  (_config : Config.t)
  (_context : Bot_runtime.Context.t)
  (_event : Exchange_event.t)
  : unit Deferred.t
  =
  Deferred.unit
;;
