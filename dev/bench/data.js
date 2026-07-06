window.BENCHMARK_DATA = {
  "lastUpdate": 1783344621907,
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
      },
      {
        "commit": {
          "author": {
            "email": "77038444+ClaraY05@users.noreply.github.com",
            "name": "ClaraY05",
            "username": "ClaraY05"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f81e78d21c35b9f45ba01499a6c8c91a58a7eab8",
          "message": "Merge pull request #1 from jane-street-immersion-program/clara/book-filler\n\nImplemented pathological bot book-filler to test for bots that attempt to overload memory.",
          "timestamp": "2026-07-06T09:26:33-04:00",
          "tree_id": "e3ab31aae7b35e0ba63a4924cc751e312da8e94b",
          "url": "https://github.com/jane-street-immersion-program/jsip-exchange-part-3-group-d/commit/f81e78d21c35b9f45ba01499a6c8c91a58a7eab8"
        },
        "date": 1783344621664,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "find_match (n=10)",
            "value": 16.999027979529657,
            "unit": "ns"
          },
          {
            "name": "find_match (n=50)",
            "value": 18.134931894535306,
            "unit": "ns"
          },
          {
            "name": "find_match (n=100)",
            "value": 19.034951339717193,
            "unit": "ns"
          },
          {
            "name": "find_match (n=500)",
            "value": 21.74027934097586,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=10)",
            "value": 16.614737602844492,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=50)",
            "value": 17.793211777416996,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=100)",
            "value": 18.577541377633644,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=500)",
            "value": 21.41866899808185,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=10)",
            "value": 127.81851428992206,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=50)",
            "value": 572.4378502619356,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=100)",
            "value": 1102.8153169959207,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=500)",
            "value": 5586.650019385092,
            "unit": "ns"
          },
          {
            "name": "add+remove (n=100)",
            "value": 307.5005862230788,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=10)",
            "value": 87.77775466156582,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=50)",
            "value": 93.27915810648983,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=100)",
            "value": 94.67177810645796,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=500)",
            "value": 93.27928652898349,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=10)",
            "value": 46.08662634458957,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=50)",
            "value": 45.473813769121,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=100)",
            "value": 45.99195182073554,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=500)",
            "value": 45.466959861548744,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_10_levels",
            "value": 5661.834759135635,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_50_levels",
            "value": 54877.70356864869,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_100_levels",
            "value": 169666.89060322702,
            "unit": "ns"
          },
          {
            "name": "find_match_alloc (n=100)",
            "value": 19.179812548450048,
            "unit": "ns"
          }
        ]
      }
    ]
  }
}