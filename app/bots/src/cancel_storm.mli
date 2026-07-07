(** A pathological bot that churns the cancel path.

    On every tick it runs [Config.cycles_per_tick] submit/cancel cycles. Each
    cycle allocates a {e fresh} {!Jsip_types.Client_order_id.t} (a monotonic
    counter, never reused), submits one passive [Day] order priced
    [Config.price_offset_cents] away from the fundamental so it rests rather
    than trades, then immediately cancels that same order. The submit is
    awaited before the cancel, and both flow through the exchange's single
    ordered request queue, so every cycle reliably yields an [Order_accept]
    followed by an [Order_cancel].

    The pathology: high submit/accept/cancel traffic on the request queue and
    every subscriber pipe, plus — because the matching engine permanently
    records every accepted client order id per participant to detect
    duplicates — unbounded growth of that per-participant table. Reusing an
    id would instead get every submit after the first rejected as a
    duplicate, so the fresh-id allocation is what keeps the storm going.

    The one random choice (each order's side) draws from
    {!Jsip_bot_runtime.Bot_runtime.Context.random}, so a fixed seed replays
    identically. See {!Jsip_scenarios.Cancel_scenario} for the driving
    scenario. *)

open! Core
open Jsip_types

module Config : sig
  (** Tuning knobs for a cancel storm. Abstract: a config can only be built
      through {!create}, which also seeds the internal client-order-id
      counter. *)
  type t [@@deriving sexp_of]

  (** Build a config from its tuning knobs:

      - [symbols]: the stock(s) to churn on;
      - [cycles_per_tick]: how many submit/cancel pairs run each tick;
      - [order_size]: shares on each order;
      - [price_offset_cents]: how far from the fundamental each order rests
        (so it never trades).

      Raises if [symbols] is empty or either of [cycles_per_tick] /
      [order_size] is non-positive. *)
  val create
    :  symbols:Symbol.t list
    -> cycles_per_tick:int
    -> order_size:int
    -> price_offset_cents:int
    -> t
end

(* Conform to the shared Bot interface so the runtime can drive this module
   like any other bot. *)
include Jsip_bot_runtime.Bot_runtime.Bot with module Config := Config
