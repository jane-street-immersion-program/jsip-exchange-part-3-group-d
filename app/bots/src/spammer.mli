(** A pathological bot: submits a large burst of orders on every tick.

    On each [on_tick], [Spammer] fires [Config.orders_per_tick] orders for
    every configured symbol, all at once — not paced to the RPC round-trip —
    so the burst genuinely floods the exchange rather than trickling one
    order at a time. Every order is a resting {!Jsip_types.Time_in_force.Day}
    order priced far enough from the market that it never crosses, so the
    pressure lands purely on the request queue, the dispatcher's per-event
    fan-out, and subscriber-pipe bandwidth — with no matching-engine work to
    muddy the picture. Each order gets a fresh
    {!Jsip_types.Client_order_id.t} so none are rejected as duplicates and
    every one rests. The bot ignores all incoming events.

    Drive it from the [Order_spam] scenario. A single spammer usually already
    saturates the request path, but {!Config.t} is per-instance, so a
    scenario can launch several under distinct participants and RNG seeds. It
    satisfies {!Jsip_bot_runtime.Bot_runtime.Bot}, so the runner treats it
    like any other bot. *)

open! Core
open! Async
open Jsip_types
open Jsip_bot_runtime

module Config : sig
  type t =
    { symbols : Symbol.t list
    (** Symbols the burst is spread across; each tick fires [orders_per_tick]
        orders for every symbol in this list. *)
    ; orders_per_tick : int
    (** Burst size, per symbol, per tick. This is the intensity knob and the
        whole point of the bot — a scenario dials the pathology up or down
        entirely through this (and the tick interval). *)
    ; order_size : int
    (** Shares per order. Fixed; since orders never cross, this only affects
        the size of resting liquidity, not fills. *)
    ; price_cents : int
    (** Fixed limit price for every order, in cents. Choose a value far from
        the market — very low for a [Buy], very high for a [Sell] — so each
        order rests instead of crossing. *)
    ; side : Side.t (** Every order is on this side. *)
    ; mutable next_client_order_id : int
    (** Internal cursor: the next client order ID to hand out. Set its
        starting value (e.g. [1]) at construction; the bot increments it so
        every order is unique for this participant. *)
    }
  [@@deriving sexp_of]
end

include Bot_runtime.Bot with module Config := Config
