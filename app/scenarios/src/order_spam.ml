open! Core
open Jsip_types
open Jsip_scenario_runner
open Jsip_bots

let name = "order-spam"

let description =
  "One or more spammers flood the request path with a burst of resting \
   orders every tick."
;;

let symbol = Symbol.of_string "AAPL"
let fundamental_price_cents = 15_000

(* A large passive offset: every (buy) order rests deep below the fundamental
   (about $1.00 at a 15000 fair) so the flood is pure request/pipe pressure,
   with no fills to muddy what we're measuring. The spammer reads the live
   fundamental and applies this offset itself, so the "always rests"
   guarantee lives in the bot rather than in a magic price picked here. *)
let passive_offset_cents = 14_900
let order_size = 10
let num_spammers = 10

(* Bound on in-flight submissions per spammer per tick: a governed flood.
   High enough that hundreds of round-trips overlap, low enough that the
   client's Async scheduler doesn't saturate before the exchange's request
   path does. *)
let max_concurrent_submits = 100

(* Per-instance intensity: each spammer fires [orders_per_tick] orders every
   [tick_interval], all at once. Aggregate flood across the crowd is roughly
   [num_spammers * orders_per_tick / tick_interval] — about 5000 orders/sec
   at these values. Dial up or down to taste. *)
let orders_per_tick = 300
let tick_interval = Time_ns.Span.of_sec 0.1

let oracle_config : Jsip_fundamental.Fundamental_oracle.Config.t =
  Symbol.Map.of_alist_exn
    [ ( symbol
      , { Jsip_fundamental.Fundamental_oracle.Config.initial_price_cents =
            fundamental_price_cents
        ; volatility_cents_per_sec = 0.0
        ; mean_reversion_strength = 0.0
        ; tick_interval = Time_ns.Span.of_sec 1.0
        } )
    ]
;;

(* Build spammer instance [index]. Each gets a DISTINCT participant name
   ([Spammer0], [Spammer1], ...) so their per-participant client-order-id
   namespaces don't collide, and a distinct [rng_seed] (unused by the
   spammer, which makes no random choices, but kept distinct for hygiene).
   All instances share the same intensity. *)
let spammer_spec ~index : Bot_spec.t =
  let config : Spammer.Config.t =
    { symbols = [ symbol ]
    ; orders_per_tick
    ; order_size
    ; passive_offset_cents
    ; side = Buy
    ; max_concurrent_submits
    ; next_client_order_id = 1
    }
  in
  Bot_spec.T
    { bot = (module Spammer)
    ; config
    ; participant = Participant.of_string [%string "Spammer%{index#Int}"]
    ; symbols = [ symbol ]
    ; rng_seed = index
    ; tick_interval
    ; is_marketdata_consumer = false
    }
;;

let configure () : Scenario_config.t =
  (* A crowd of [num_spammers], each flooding under its own identity. More
     instances means more request-path and subscriber-pipe pressure, since
     each opens its own session. Set [num_spammers] to 1 for a single
     instance. *)
  { name
  ; symbols = [ symbol ]
  ; oracle_config
  ; news = []
  ; bots = List.init num_spammers ~f:(fun index -> spammer_spec ~index)
  }
;;
