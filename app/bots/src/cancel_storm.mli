(** A pathological bot that churns the cancel path.

    On every tick the cancel storm runs [Config.cycles_per_tick] submit /
    cancel cycles. Each cycle:

    - allocates a {e fresh} {!Jsip_types.Client_order_id.t} (a monotonically
      increasing counter, never reused);
    - submits a single passive [Day] order priced [Config.price_offset_cents]
      {e away} from the current fundamental (a buy below it, a sell above it)
      so it rests on the book rather than filling immediately;
    - immediately cancels that same order by its client order id.

    The submit is awaited before the cancel is issued, and both flow through
    the exchange's single ordered request queue, so the engine reliably
    produces an [Order_accept] followed by an [Order_cancel] for every cycle.

    The pressure this exerts: a high rate of submit/accept/cancel event
    traffic on the request queue and every subscriber pipe, and — because the
    matching engine permanently records every accepted client order id per
    participant to detect duplicates — steady, unbounded growth of that
    per-participant bookkeeping table. Reusing a client order id would
    instead get every submit after the first rejected as a duplicate, so the
    fresh-id allocation is what keeps the storm going.

    The only random choice the bot makes (which side each order takes) draws
    from {!Jsip_bot_runtime.Bot_runtime.Context.random}, so a scenario with a
    fixed seed replays identically.

    See {!Jsip_scenarios.Cancel_storm} for the scenario that drives it. *)

open! Core
open Jsip_types

module Config : sig
  type t = private
    { symbols : Symbol.t list
    (** Symbols the bot churns on. Each cycle round-robins to the next
        symbol, so a multi-symbol list spreads the storm across books. Must
        be non-empty. *)
    ; cycles_per_tick : int
    (** Submit/cancel cycles performed on every tick. This is the main
        intensity knob: the effective request rate is roughly
        [cycles_per_tick / tick_interval] submits (and as many cancels) per
        second. Typical values range from a gentle [5] to an aggressive
        [200+]. Must be positive. *)
    ; order_size : int
    (** Shares on each submitted order, in units. The orders are cancelled
        before they can trade, so this mostly affects how the churn looks in
        the audit log. Must be positive. *)
    ; price_offset_cents : int
    (** How far, in cents, each order is priced away from the fundamental so
        it rests without filling: a buy at
        [fundamental - price_offset_cents], a sell at
        [fundamental + price_offset_cents]. Should be comfortably wider than
        any market maker's half-spread so the orders never become marketable. *)
    ; mutable next_client_order_id : int
    (** Internal: the next client order id to allocate. Not a tuning knob —
        it is seeded by {!create} and mutated forward one step per cycle so
        every submitted order carries a never-before-used id. *)
    }
  [@@deriving sexp_of]

  (** Build a config from its tuning knobs. The internal client-order-id
      counter is seeded automatically. Raises if [symbols] is empty or any of
      [cycles_per_tick] / [order_size] is non-positive. *)
  val create
    :  symbols:Symbol.t list
    -> cycles_per_tick:int
    -> order_size:int
    -> price_offset_cents:int
    -> t
end

include Jsip_bot_runtime.Bot_runtime.Bot with module Config := Config
