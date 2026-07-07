(* The "cancel-storm" scenario: boots an exchange and points a few
   Cancel_storm bots at it. [configure] returns a [Scenario_config.t] recipe;
   the scenario runner turns it into a live exchange + bots. *)

open! Core
open Jsip_types
open Jsip_scenario_runner
module Cancel_storm_bot = Jsip_bots.Cancel_storm

(* Typed after [-scenario] on the command line to pick this. *)
let name = "cancel-storm"

let description =
  "Several bots that submit a passive order and immediately cancel it, over \
   and over, hammering the cancel path."
;;

let symbol = Symbol.of_string "AAPL"
let fair_value_cents = 15_000

(* Deliberately no market maker or noise trader: the cancel storm cancels its
   OWN resting orders and never wants to trade, so it needs no counterparty.
   Several copies just amplify the pressure so the effect shows up fast. *)
let num_bots = 3
let cycles_per_tick = 50
let order_size = 10

(* Sit well away from the fair price so orders rest instead of trading. *)
let price_offset_cents = 500
let tick_interval = Time_ns.Span.of_ms 50.

let bot_spec ~index : Bot_spec.t =
  let participant =
    Participant.of_string [%string "CancelStorm%{index#Int}"]
  in
  let config =
    Cancel_storm_bot.Config.create
      ~symbols:[ symbol ]
      ~cycles_per_tick
      ~order_size
      ~price_offset_cents
  in
  T
    { bot = (module Cancel_storm_bot)
    ; config
    ; participant
    ; symbols = [ symbol ]
    ; rng_seed = index (* seeds Context.random; distinct per bot *)
    ; tick_interval
    ; (* prices off the fundamental, not the live book, so no market-data
         subscription is needed *)
      is_marketdata_consumer = false
    }
;;

let configure () : Scenario_config.t =
  { name
  ; symbols = [ symbol ]
  ; oracle_config =
      (* Flat fundamental (zero volatility, no mean reversion) so the
         scenario is calm and deterministic — the storm is the only thing
         happening. *)
      Symbol.Map.of_alist_exn
        [ ( symbol
          , { Jsip_fundamental.Fundamental_oracle.Config.initial_price_cents =
                fair_value_cents
            ; volatility_cents_per_sec = 0.
            ; mean_reversion_strength = 0.
            ; tick_interval = Time_ns.Span.of_sec 1.
            } )
        ]
  ; news = []
  ; bots = List.init num_bots ~f:(fun index -> bot_spec ~index)
  }
;;
