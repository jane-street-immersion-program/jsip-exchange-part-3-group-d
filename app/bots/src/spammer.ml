open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime

module Config = struct
  type t =
    { symbols : Symbol.t list
    ; orders_per_tick : int
    ; order_size : int
    ; passive_offset_cents : int
    ; side : Side.t
    ; max_concurrent_submits : int
    ; mutable next_client_order_id : int
    }
  [@@deriving sexp_of]
end

let name = "spammer"

(* No startup work: all of the bot's pressure lives in [on_tick]. *)
let on_start (_ : Config.t) (_ : Bot_runtime.Context.t) = Deferred.unit

(* The spammer only produces events; it never reacts to them. *)
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
let fresh_client_order_id (config : Config.t) =
  let id = config.next_client_order_id in
  config.next_client_order_id <- id + 1;
  Client_order_id.of_int id
;;

(* Price one order on the passive side of the current fundamental so it rests
   instead of crossing: a [Buy] sits [passive_offset_cents] below [fair], a
   [Sell] the same distance above. Anchoring to the live fundamental (rather
   than a fixed price chosen by the scenario) keeps the "orders always rest"
   guarantee inside the bot, so no scenario misconfiguration can turn this
   flood into matching-engine work. *)
let passive_price (config : Config.t) fair =
  let offset = Price.of_int_cents config.passive_offset_cents in
  match config.side with
  | Buy -> Price.( - ) fair offset
  | Sell -> Price.( + ) fair offset
;;

(* One deliberately non-marketable resting order at [price] (see
   {!passive_price}). *)
let make_request (config : Config.t) ~client_order_id ~symbol ~price
  : Order.Request.t
  =
  { client_order_id
  ; symbol
  ; side = config.side
  ; price
  ; size = Size.of_int config.order_size
  ; time_in_force = Day
  }
;;

(* Fire one request at the exchange. [Context.submit] is one-way: it returns
   once the server has enqueued the request, and the accept/reject arrives
   later on the session feed (which this bot ignores). *)
let submit (ctx : Bot_runtime.Context.t) request =
  match%map Bot_runtime.Context.submit ctx request with
  | Ok () -> ()
  | Error err ->
    [%log.error
      "spammer: submit failed" (request : Order.Request.t) (err : Error.t)]
;;

let on_tick (config : Config.t) (ctx : Bot_runtime.Context.t) =
  (* Build the full burst for this tick: [orders_per_tick] fresh orders for
     every symbol, each priced off that symbol's current fundamental so they
     rest. Assembling the requests (with fresh IDs) is the easy part; how
     you *send* them is what makes this bot a spammer rather than a normal
     trader. *)
  let burst =
    List.concat_map config.symbols ~f:(fun symbol ->
      let price =
        passive_price config (Bot_runtime.Context.fundamental ctx symbol)
      in
      List.init config.orders_per_tick ~f:(fun (_ : int) ->
        let client_order_id = fresh_client_order_id config in
        make_request config ~client_order_id ~symbol ~price))
  in
  (* Fire the burst with up to [max_concurrent_submits] requests in flight at
     once. This still floods — many round-trips overlap instead of trickling
     one per reply the way [`Sequential] would — but bounding the concurrency
     keeps a huge [orders_per_tick] from saturating the client's Async
     scheduler (or tripping server-side rate limits) before the request path
     itself becomes the bottleneck we mean to stress. *)
  Deferred.List.iter
    ~how:(`Max_concurrent_jobs config.max_concurrent_submits)
    burst
    ~f:(submit ctx)
;;
