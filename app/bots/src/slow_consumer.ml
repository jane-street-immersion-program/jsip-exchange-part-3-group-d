open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime

(* A pathological *consumer*: it subscribes to a feed and then reads it
   slower than the exchange produces onto it, so the exchange-side buffer
   (the Async [Pipe] holding events for this subscriber) grows without bound.

   The slowness lives in [on_event]. The scenario runner drains each
   subscribed feed with [Pipe.iter ~f:on_event] (see
   [Runner.subscribe_and_iter_event_pipe]), and [Pipe.iter] is sequential: it
   will not read the next event until the [Deferred.t] returned by [on_event]
   resolves. So sleeping [read_delay] in [on_event] caps the client's read
   rate at one event per [read_delay]. When the exchange produces faster than
   that, the unread events back up through the RPC transport onto the
   exchange-side pipe — which the exchange fills with
   [Pipe.write_without_pushback_if_open] and so never bounds. Its misbehavior
   is entirely on the read side; it submits no orders, so [on_tick] does
   nothing. *)

module Config = struct
  type t =
    { read_delay : Time_ns.Span.t
    (* How long [on_event] sleeps before returning, throttling the runner's
       sequential read loop to at most one event per [read_delay]. The core
       intensity knob. [Time_ns.Span.zero] disables the throttle (a
       well-behaved reader — useful as a control); a very large span
       approximates a consumer that subscribes and then never reads. *)
    }
  [@@deriving sexp_of]
end

let name = "slow_consumer"

let on_start (_config : Config.t) (_context : Bot_runtime.Context.t)
  : unit Deferred.t
  =
  (* Nothing to prime. The feeds this bot subscribes to is decided by the
     scenario's [Bot_spec.t] (the session feed is always subscribed; set
     [is_marketdata_consumer = true] and list [symbols] to aim the busier
     market-data firehose at this reader). *)
  Deferred.unit
;;

let on_tick (_config : Config.t) (_context : Bot_runtime.Context.t)
  : unit Deferred.t
  =
  (* A slow consumer only reads; it never submits or cancels. *)
  Deferred.unit
;;

let on_event
  (config : Config.t)
  (_context : Bot_runtime.Context.t)
  (_event : Exchange_event.t)
  : unit Deferred.t
  =
  Clock_ns.after config.read_delay
;;
