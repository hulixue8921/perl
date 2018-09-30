curl -X POST "192.168.1.34:9200/website/logs/_bulk" -H 'Content-Type: application/json' -d'
{ "index": {}}
{ "latency" : 500000, "zone" : "US", "timestamp" : "2017-10-28" }
'

