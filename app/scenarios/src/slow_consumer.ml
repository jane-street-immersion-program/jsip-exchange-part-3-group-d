open! Core
open Jsip_types
open Jsip_scenario_runner
module Fundamental_oracle = Jsip_fundamental.Fundamental_oracle
module Bot_runtime = Jsip_bot_runtime.Bot_runtime

let name = "slow-consumers"

let description =
  "A fleet of slow consumers subscribe to market data and read their pipes \
   far slower than the exchange produces onto them, so the exchange-side \
   buffers grow without bound. A book filler supplies the market-data \
   firehose by churning the BBO as the fundamental drifts."
;;

(* The symbol(s) the scenario runs on. This drives
   - the exchange's known symbols
   - the oracle's price process
   - the symbols the book filler targets *)
let symbols = [ Symbol.of_string "AAPL" ]

(* fundamental: higher volatility to create drifting fair value and new posts
   for best bid and best ask via the book filler, which is what generates the
   steady stream of [Best_bid_offer_update] market-data events the consumers
   fall behind on. *)
let oracle_config : Fundamental_oracle.Config.t =
  Symbol.Map.of_alist_exn
    (List.map symbols ~f:(fun symbol ->
       ( symbol
       , ({ initial_price_cents = 15000
          ; volatility_cents_per_sec = 10.0
          ; mean_reversion_strength = 0.1
          ; tick_interval = Time_ns.Span.of_ms 250.0
          }
          : Fundamental_oracle.Config.symbol_config) )))
;;

(* How many slow consumers to launch. Effect on the exchange process's RSS
   becomes obvious with a crowd, since each consumer holds its own unbounded
   buffer. *)
let num_slow_consumers = 10

(* Each consumer sleeps this long in [on_event]. Given value is far longer
   than the ~30s demo window, so in practice every consumer subscribes and
   then never drains. Shorten this to model a consumer that reads slowly
   rather than not at all. *)
let read_delay = Time_ns.Span.of_sec 60.0

(* The producer. A book filler churns the BBO as the fundamental drifts,
   supplies the market-data volume the consumers choke on. *)
let book_filler_spec () : Bot_spec.t =
  let config : Jsip_bots.Book_filler.Config.t =
    { symbols
    ; orders_per_tick = 50
    ; order_size = 100
    ; min_offset = 5
    ; max_random_offset = 50
    ; next_client_id = 1
    }
  in
  Bot_spec.T
    { bot =
        (module Jsip_bots.Book_filler : Bot_runtime.Bot
          with type Config.t = Jsip_bots.Book_filler.Config.t)
    ; config
    ; participant = Participant.of_string "BookFiller"
    ; symbols
    ; rng_seed = 0
    ; tick_interval = Time_ns.Span.of_ms 250.0
    ; is_marketdata_consumer = false
    }
;;

(* One slow consumer. [is_marketdata_consumer = true] is what makes the
   runner subscribe it to the [AAPL] market-data feed — the busy pipe it then
   refuses to drain. *)
let slow_consumer_spec index : Bot_spec.t =
  let config : Jsip_bots.Slow_consumer.Config.t = { read_delay } in
  Bot_spec.T
    { bot =
        (module Jsip_bots.Slow_consumer : Bot_runtime.Bot
          with type Config.t = Jsip_bots.Slow_consumer.Config.t)
    ; config
    ; participant =
        Participant.of_string [%string "SlowConsumer%{index#Int}"]
    ; symbols
    ; rng_seed = index
    ; tick_interval = Time_ns.Span.of_sec 1.0
    ; is_marketdata_consumer = true
    }
;;

let configure () : Scenario_config.t =
  { name
  ; symbols
  ; oracle_config
  ; news = []
  ; bots =
      book_filler_spec ()
      :: List.init num_slow_consumers ~f:(fun i ->
        slow_consumer_spec (i + 1))
  }
;;
