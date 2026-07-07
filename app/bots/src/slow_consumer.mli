(** A pathological bot that subscribes to a feed and then reads it slower
    than the exchange produces onto it, so the exchange-side buffer — the
    Async [Pipe] holding events for this subscriber — grows without bound.

    Unlike the other pathological bots, its misbehavior is entirely on the
    read side: it submits no orders. It works by dawdling inside [on_event].
    The scenario runner drains each subscribed feed, it does not read the
    next event until [on_event]'s [Deferred.t] resolves. Sleeping
    [Config.read_delay] in [on_event] therefore caps the client's read rate;
    when the exchange produces faster than that, the unread events back up
    through the RPC transport onto the exchange-side pipe, which the exchange
    fills with [Pipe.write_without_pushback_if_open] and so never bounds.
    Left running, this drives the exchange process's memory up — the pressure
    the Part 3 bounded-pipe defenses are meant to contain.

    Which feeds it subscribes to is chosen by the scenario via the bot's
    [Bot_spec.t], not by this module: the session feed is always subscribed,
    and setting [is_marketdata_consumer = true] with a list of [symbols] aims
    the busier market-data firehose at this reader. To make the pathology
    obvious a scenario can launch several copies with distinct participant
    names. *)

open! Core
open! Async

module Config : sig
  type t =
    { read_delay : Time_ns.Span.t
    (** How long [on_event] sleeps before returning, throttling the runner's
        sequential [Pipe.iter] read loop to at most one event per
        [read_delay]. The larger it is relative to the exchange's event rate,
        the faster the exchange-side buffer grows. *)
    }
  [@@deriving sexp_of]
end

include Jsip_bot_runtime.Bot_runtime.Bot with module Config := Config
