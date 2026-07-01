window.BENCHMARK_DATA = {
  "lastUpdate": 1782880757424,
  "repoUrl": "https://github.com/jane-street-immersion-program/jsip-exchange-part-3-group-d",
  "entries": {
    "Order book benchmark": [
      {
        "commit": {
          "author": {
            "email": "abauer@janestreet.com",
            "name": "Aaron Bauer",
            "username": "awilliambauer"
          },
          "committer": {
            "email": "abauer@janestreet.com",
            "name": "Aaron Bauer",
            "username": "awilliambauer"
          },
          "distinct": true,
          "id": "72568f047cf4d001fc705874ba88077cd9b5423e",
          "message": "ai intro, part 3 exercises, claude code files",
          "timestamp": "2026-07-01T04:34:19Z",
          "tree_id": "78d26c220c6fa48f14ba23bc009b50efe07aee98",
          "url": "https://github.com/jane-street-immersion-program/jsip-exchange-part-3-group-d/commit/72568f047cf4d001fc705874ba88077cd9b5423e"
        },
        "date": 1782880756820,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "find_match (n=10)",
            "value": 21.781113002146597,
            "unit": "ns"
          },
          {
            "name": "find_match (n=50)",
            "value": 23.00448292391068,
            "unit": "ns"
          },
          {
            "name": "find_match (n=100)",
            "value": 23.97048880854896,
            "unit": "ns"
          },
          {
            "name": "find_match (n=500)",
            "value": 26.54494733109178,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=10)",
            "value": 22.025970151017173,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=50)",
            "value": 23.295974931731163,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=100)",
            "value": 24.242785450630457,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=500)",
            "value": 26.60557124700312,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=10)",
            "value": 143.90925112269827,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=50)",
            "value": 605.2064553835339,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=100)",
            "value": 1193.5148051444899,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=500)",
            "value": 5853.1158190167935,
            "unit": "ns"
          },
          {
            "name": "add+remove (n=100)",
            "value": 363.0405922227916,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=10)",
            "value": 112.0167872916946,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=50)",
            "value": 117.5241657260684,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=100)",
            "value": 116.93702754562008,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=500)",
            "value": 116.87334280859397,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=10)",
            "value": 57.935197018952984,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=50)",
            "value": 57.39362957631083,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=100)",
            "value": 57.600986449170875,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=500)",
            "value": 57.26858521809516,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_10_levels",
            "value": 6953.917645269902,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_50_levels",
            "value": 64599.75008998949,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_100_levels",
            "value": 200131.45247789257,
            "unit": "ns"
          },
          {
            "name": "find_match_alloc (n=100)",
            "value": 24.068430389227085,
            "unit": "ns"
          }
        ]
      }
    ]
  }
}