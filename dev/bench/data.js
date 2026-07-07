window.BENCHMARK_DATA = {
  "lastUpdate": 1783449075914,
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
      },
      {
        "commit": {
          "author": {
            "email": "115841955+BenFukuzawa@users.noreply.github.com",
            "name": "BenFukuzawa",
            "username": "BenFukuzawa"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "987873bdb23b251913e052ab4c7824fbda937bc3",
          "message": "Merge pull request #2 from jane-street-immersion-program/clara/slow-consumer\n\nfeat: implemented bot behavior of slow_consumer",
          "timestamp": "2026-07-07T12:04:09-04:00",
          "tree_id": "a3730e7b0a51f0d4e5b609ffe025042a16ae551d",
          "url": "https://github.com/jane-street-immersion-program/jsip-exchange-part-3-group-d/commit/987873bdb23b251913e052ab4c7824fbda937bc3"
        },
        "date": 1783440525278,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "find_match (n=10)",
            "value": 12.460168886265148,
            "unit": "ns"
          },
          {
            "name": "find_match (n=50)",
            "value": 13.509709368714077,
            "unit": "ns"
          },
          {
            "name": "find_match (n=100)",
            "value": 13.764909058453608,
            "unit": "ns"
          },
          {
            "name": "find_match (n=500)",
            "value": 14.685307349825917,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=10)",
            "value": 13.285285203339265,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=50)",
            "value": 14.142773129909127,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=100)",
            "value": 14.701404837352921,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=500)",
            "value": 15.702778811770846,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=10)",
            "value": 75.10940566648459,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=50)",
            "value": 337.0879063992396,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=100)",
            "value": 661.5584807496703,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=500)",
            "value": 3213.4872872421242,
            "unit": "ns"
          },
          {
            "name": "add+remove (n=100)",
            "value": 209.77872776112483,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=10)",
            "value": 57.57264492232901,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=50)",
            "value": 62.82148402821997,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=100)",
            "value": 61.383692467674216,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=500)",
            "value": 59.420679029505614,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=10)",
            "value": 30.242780797717035,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=50)",
            "value": 30.518287972178776,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=100)",
            "value": 30.26778265509458,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=500)",
            "value": 30.37599145809275,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_10_levels",
            "value": 3555.683085848308,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_50_levels",
            "value": 36305.65454307595,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_100_levels",
            "value": 113438.33590030253,
            "unit": "ns"
          },
          {
            "name": "find_match_alloc (n=100)",
            "value": 14.954689008122903,
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
          "id": "09f70a50d7b994eac72186795133bdc515085c48",
          "message": "Merge pull request #3 from jane-street-immersion-program/ben-spammer-bot\n\nBen spammer bot, REFACTOR config into abstract type later.",
          "timestamp": "2026-07-07T13:58:58-04:00",
          "tree_id": "b15e199be557ce3dd8631fb18098413ed1c9c9a6",
          "url": "https://github.com/jane-street-immersion-program/jsip-exchange-part-3-group-d/commit/09f70a50d7b994eac72186795133bdc515085c48"
        },
        "date": 1783447427670,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "find_match (n=10)",
            "value": 21.60937034719335,
            "unit": "ns"
          },
          {
            "name": "find_match (n=50)",
            "value": 22.83996853045339,
            "unit": "ns"
          },
          {
            "name": "find_match (n=100)",
            "value": 23.72014691657397,
            "unit": "ns"
          },
          {
            "name": "find_match (n=500)",
            "value": 26.426599035895894,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=10)",
            "value": 22.1401075464554,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=50)",
            "value": 23.701291161967067,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=100)",
            "value": 24.361932748305545,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=500)",
            "value": 26.64096100165982,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=10)",
            "value": 154.17697207011875,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=50)",
            "value": 654.2184165118429,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=100)",
            "value": 1288.8003574456695,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=500)",
            "value": 6319.928934386413,
            "unit": "ns"
          },
          {
            "name": "add+remove (n=100)",
            "value": 392.7952285418085,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=10)",
            "value": 114.61900232009057,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=50)",
            "value": 122.69807037515129,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=100)",
            "value": 119.90638543085248,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=500)",
            "value": 118.75785262262177,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=10)",
            "value": 57.94268600735693,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=50)",
            "value": 57.85544320880607,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=100)",
            "value": 58.21784325465566,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=500)",
            "value": 57.95761764407371,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_10_levels",
            "value": 6970.078665933064,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_50_levels",
            "value": 67739.14134053892,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_100_levels",
            "value": 211915.48932494252,
            "unit": "ns"
          },
          {
            "name": "find_match_alloc (n=100)",
            "value": 24.65086521584138,
            "unit": "ns"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "115841955+BenFukuzawa@users.noreply.github.com",
            "name": "BenFukuzawa",
            "username": "BenFukuzawa"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "e4e7e67a1e5b96ef48b92e509f1aca86848be473",
          "message": "Merge pull request #4 from jane-street-immersion-program/minhaz-cancel-bot\n\nCancel-bot merge pull request",
          "timestamp": "2026-07-07T14:27:52-04:00",
          "tree_id": "ada7653aa27b985dd79a78f7a942f7d5f4884e47",
          "url": "https://github.com/jane-street-immersion-program/jsip-exchange-part-3-group-d/commit/e4e7e67a1e5b96ef48b92e509f1aca86848be473"
        },
        "date": 1783449075587,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "find_match (n=10)",
            "value": 25.282145055873453,
            "unit": "ns"
          },
          {
            "name": "find_match (n=50)",
            "value": 26.314935976532627,
            "unit": "ns"
          },
          {
            "name": "find_match (n=100)",
            "value": 27.005187364493253,
            "unit": "ns"
          },
          {
            "name": "find_match (n=500)",
            "value": 30.183375710522387,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=10)",
            "value": 24.539210666047016,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=50)",
            "value": 26.936555846889426,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=100)",
            "value": 27.621349000618775,
            "unit": "ns"
          },
          {
            "name": "find_match_miss (n=500)",
            "value": 30.87064680185289,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=10)",
            "value": 155.09251101033237,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=50)",
            "value": 653.3638903011506,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=100)",
            "value": 1272.6588887689952,
            "unit": "ns"
          },
          {
            "name": "best_bid_offer (n=500)",
            "value": 6281.423545618286,
            "unit": "ns"
          },
          {
            "name": "add+remove (n=100)",
            "value": 440.2770550240276,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=10)",
            "value": 118.44505525654786,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=50)",
            "value": 119.79027190022711,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=100)",
            "value": 119.28760982400964,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_cross (n=500)",
            "value": 116.76382229296915,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=10)",
            "value": 58.691811848063125,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=50)",
            "value": 58.783778609444575,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=100)",
            "value": 57.74634270706278,
            "unit": "ns"
          },
          {
            "name": "submit_ioc_miss (n=500)",
            "value": 57.71007703378539,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_10_levels",
            "value": 7462.262267565249,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_50_levels",
            "value": 72214.32304306449,
            "unit": "ns"
          },
          {
            "name": "submit_sweep_100_levels",
            "value": 230485.87860947382,
            "unit": "ns"
          },
          {
            "name": "find_match_alloc (n=100)",
            "value": 28.458503226621122,
            "unit": "ns"
          }
        ]
      }
    ]
  }
}