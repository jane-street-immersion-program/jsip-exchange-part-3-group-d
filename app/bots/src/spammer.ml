open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime

module Config = struct
  type t =
    { symbols : Symbol.t list
    ; orders_per_tick : int
    ; order_size : int
    ; price_cents : int
    ; side : Side.t
    ; mutable next_client_order_id : int
    }
  [@@deriving sexp_of]
end

let name = "spammer"

(* No startup work: all of the bot's pressure lives in [on_tick]. *)
let on_start (_ : Config.t) (_ : Bot_runtime.Context.t) = Deferred.unit

(* The spammer only produces events; it never reacts to them. *)
(* how many were accpeted increment the value *)
let on_event
  (_ : Config.t)
  (_ : Bot_runtime.Context.t)
  (_ : Exchange_event.t)
  =
  Deferred.unit
;;

(* Hand out a unique client order ID and advance the cursor. Every resting
   order needs its own ID: the orders below are non-marketable Day orders
   that never leave the book, so their IDs stay in use forever and any reuse
   would be rejected by the matching engine as a duplicate. *)
(* CR: I believe this helper does not need to be exposed as much, it is only
   called in on tick and would function fine as a nested helper function *)
let fresh_client_order_id (config : Config.t) =
  let id = config.next_client_order_id in
  config.next_client_order_id <- id + 1;
  Client_order_id.of_int id
;;

(* One fixed, deliberately non-marketable resting order. [price_cents] is
   chosen by the scenario to sit far from the market (very low for a buy,
   very high for a sell), so the order rests instead of crossing — the
   pressure lands on the request queue and subscriber pipes, not the matching
   engine. *)
(* CR: If you want orders to always be resting instead of crossing I think it
   would be more intuitive to add that restraint to the bot design and not
   enforce it through the scenario setup (see note about fundamental). If
   there was a design restraint that prevented this please let me know. *)
(* CR: See note on fresh_client_order_id about nested helper *)
let make_request (config : Config.t) ~client_order_id ~symbol
  : Order.Request.t
  =
  { client_order_id
  ; symbol
  ; side = config.side
  ; price = Price.of_int_cents config.price_cents
  ; size = Size.of_int config.order_size
  ; time_in_force = Day
  }
;;

(* Fire one request at the exchange. [Context.submit] is one-way: it returns
   once the server has enqueued the request, and the accept/reject arrives
   later on the session feed (which this bot ignores). *)
(* CR: See note on fresh_client_order_id about nested helper *)
let submit (ctx : Bot_runtime.Context.t) request =
  match%map Bot_runtime.Context.submit ctx request with
  | Ok () -> ()
  | Error err ->
    [%log.error
      "spammer: submit failed" (request : Order.Request.t) (err : Error.t)]
;;

let on_tick (config : Config.t) (ctx : Bot_runtime.Context.t) =
  (* Build the full burst for this tick: [orders_per_tick] fresh orders for
     every symbol. Assembling the requests (with fresh IDs) is the easy part;
     how you *send* them is what makes this bot a spammer rather than a
     normal trader. *)
  let burst =
    List.concat_map config.symbols ~f:(fun symbol ->
      List.init config.orders_per_tick ~f:(fun (_ : int) ->
        let client_order_id = fresh_client_order_id config in
        make_request config ~client_order_id ~symbol))
  in
  (* Fire the whole burst at once: [`Parallel] issues every submit before
     awaiting any reply, so all the round-trips overlap and the requests hit
     the exchange as a flood. [`Sequential] here would trickle one order per
     round-trip and defeat the purpose. *)
  (* CR: Try Max_concurrent_jobs instead of parallel to reduce chance of
     throttling or add a note about a high orders_per_tick potentially
     causing throttling *)
  Deferred.List.iter ~how:`Parallel burst ~f:(submit ctx)
;;
(* max concurrent job *)
