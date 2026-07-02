open! Core
open Jsip_types
open Jsip_scenario_runner
module Cancel_storm_bot = Jsip_bots.Cancel_storm

let name = "cancel-storm"

let description =
  "Several bots that submit a passive order and immediately cancel it, over \
   and over, hammering the cancel path."
;;

(* Single quiet symbol. The cancel storm prices its orders off the
   fundamental oracle (not the BBO), so a flat, deterministic fundamental is
   all it needs. *)
let symbol = Symbol.of_string "AAPL"
let fair_value_cents = 15_000

(* The storm is driven entirely by the cancel-storm bots. There is
   deliberately no market maker or noise trader: the pathology is the
   submit/accept/cancel churn and the ever-growing per-participant
   duplicate-id table, and the bot cancels its {e own} resting orders, so it
   never needs a counterparty to trade against. Running several copies under
   distinct participant names amplifies the pressure and makes it obvious
   within a few seconds. *)
let num_bots = 3
let cycles_per_tick = 50
let order_size = 10

(* Rest orders $5 off the fundamental so they never become marketable and
   always rest-then-cancel cleanly. *)
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
    ; rng_seed = index
    ; tick_interval
    ; is_marketdata_consumer = false
    }
;;

let configure () : Scenario_config.t =
  { name
  ; symbols = [ symbol ]
  ; oracle_config =
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
