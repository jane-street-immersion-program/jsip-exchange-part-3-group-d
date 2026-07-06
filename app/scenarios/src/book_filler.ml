open! Core
open Jsip_types
open Jsip_scenario_runner
module Fundamental_oracle = Jsip_fundamental.Fundamental_oracle
module Bot_runtime = Jsip_bot_runtime.Bot_runtime

let name = "book-fill"

let description =
  "Single book filler piling resting Day orders onto one symbol to grow the \
   order book."
;;

(* The symbol(s) the scenario runs on. This drives
   - the exchange's known symbols
   - the oracle's price process
   - the symbols the book filler targets *)
let symbols = [ Symbol.of_string "AAPL" ]

(* Fair-value process the book filler prices against. One entry per symbol.
   Tune these to change where the fundamental sits and how much it drifts. *)
let oracle_config : Fundamental_oracle.Config.t =
  Symbol.Map.of_alist_exn
    (List.map symbols ~f:(fun symbol ->
       ( symbol
       , ({ initial_price_cents = 15000
          ; volatility_cents_per_sec = 1.0
          ; mean_reversion_strength = 0.1
          ; tick_interval = Time_ns.Span.of_sec 1.0
          }
          : Fundamental_oracle.Config.symbol_config) )))
;;

(* How many independent book fillers to launch. The pathology is evident with
   one aggressive book filler, but launching several exercises the
   per-participant defenses from Section 3 against multiple attackers at
   once. *)
let num_book_fillers = 4

(* Build the [index]th book filler. Two things are made distinct per copy:

   - [participant]: each copy is a different exchange participant.
   - [rng_seed]: distinct seeds give each copy an independent, reproducible
     stream of side / price / size choices, so the crowd fills the book with
     varied orders

   Everything else is shared here, but [Book_filler.Config.t] is fully
   per-instance, so you can also tune [orders_per_tick], [order_size], or the
   offset knobs per copy by varying them off [index].

   Built inside a function (not a top-level value) because
   [Config.next_client_id] is mutable: each spec gets its own fresh counter. *)
let book_filler_spec ~index : Bot_spec.t =
  let config : Jsip_bots.Book_filler.Config.t =
    { symbols
    ; orders_per_tick = 50
    ; order_size = 100
    ; min_offset = 100
    ; max_random_offset = 500
    ; next_client_id = 1
    }
  in
  Bot_spec.T
    { bot =
        (module Jsip_bots.Book_filler : Bot_runtime.Bot
          with type Config.t = Jsip_bots.Book_filler.Config.t)
    ; config
    ; participant = Participant.of_string [%string "BookFiller-%{index#Int}"]
    ; symbols
    ; rng_seed = index
    ; tick_interval = Time_ns.Span.of_ms 250.0
    ; is_marketdata_consumer = false
    }
;;

let configure () : Scenario_config.t =
  { name
  ; symbols
  ; oracle_config
  ; news = []
  ; bots =
      List.init num_book_fillers ~f:(fun index -> book_filler_spec ~index)
  }
;;
