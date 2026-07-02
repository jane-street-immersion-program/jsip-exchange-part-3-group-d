(** A pathological bot that piles resting Day orders onto the book without
    intending for them to fill.

    Its whole job is to grow the order book: on every tick it submits a batch
    of new Day orders priced far enough from the touch that they rest instead
    of matching. Left running, this drives up memory in the order book and
    the latency of [find_match] / book snapshots, since every operation now
    walks a much larger book. It targets the exchange's resource dimension,
    not its correctness.

    This module satisfies {!Jsip_bot_runtime.Bot_runtime.Bot}, so a scenario
    can hand it to {!Jsip_bot_runtime.Bot_runtime.create} alongside the
    market maker and noise trader, exactly like the Part 2 bots. *)

open! Core
open! Async
open Jsip_types

module Config : sig
  type t =
    { symbols : Symbol.t list
    (** Symbols the bot piles orders on. It submits [orders_per_tick] orders
        for each symbol every tick. *)
    ; orders_per_tick : int
    (** Resting orders to add per symbol each tick — the primary intensity
        knob. A single tick creates [orders_per_tick * List.length symbols]
        orders in total; larger values fill the book faster. *)
    ; order_size : int
    (** Upper bound on order size, in whole shares. Each order's size is
        drawn uniformly at random from [[1, order_size]]. *)
    ; min_offset : int
    (** Smallest distance, in cents, between an order's price and the current
        fundamental. Every order rests at least this far from fair value so
        it stays out of the market and does not fill. Must be positive. *)
    ; max_random_offset : int
    (** Width, in cents, of the random distance added on top of [min_offset].
        Each order sits [min_offset] plus a uniform random draw from
        [[0, max_random_offset]] cents away from the fundamental — i.e.
        between [min_offset] and [min_offset + max_random_offset] cents deep.
        Must be non-negative; [0] disables the jitter and rests every order
        exactly [min_offset] from fair. *)
    ; mutable next_client_id : int
    (** Next [Client_order_id.t] to hand out, as an int. The bot stamps this
        onto its next order and then increments it, so every order gets a
        fresh, unique id (reusing one would trip the exchange's duplicate-id
        detection). Set the scenario's starting value so it can't collide
        with ids other bots use on the same book. *)
    }
  [@@deriving sexp_of]
end

include Jsip_bot_runtime.Bot_runtime.Bot with module Config := Config
