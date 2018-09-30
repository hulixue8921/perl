curl -X POST "192.168.1.34:9200/website/logs/_bulk" -H 'Content-Type: application/json' -d'
{ "index": {}}
{ "latency" : 100, "zone" : "EU", "timestamp" : "2017-10-28" }
{ "index": {}}
{ "latency" : 100, "zone" : "EU", "timestamp" : "2017-10-29" }
{ "index": {}}
{ "latency" : 50, "zone" : "EU", "timestamp" : "2017-10-29" }
{ "index": {}}
{ "latency" : 50, "zone" : "EU", "timestamp" : "2017-10-28" }
{ "index": {}}
{ "latency" : 50, "zone" : "EU", "timestamp" : "2017-10-28" }
{ "index": {}}
{ "latency" : 50, "zone" : "EU", "timestamp" : "2017-10-29" }
{ "index": {}}
{ "latency" : 100, "zone" : "EU", "timestamp" : "2017-10-29" }
{ "index": {}}
{ "latency" : 100, "zone" : "EU", "timestamp" : "2017-10-29" }
{ "index": {}}
{ "latency" : 200, "zone" : "EU", "timestamp" : "2017-10-29" }
{ "index": {}}
{ "latency" : 200, "zone" : "EU", "timestamp" : "2017-10-29" }
'

