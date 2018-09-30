curl -X GET "192.168.1.34:9200/mlratings/_search" -H 'Content-Type: application/json' -d'
{
      "size" : 0, 
            "query": {
                    "filtered": {
                              "filter": {
                                          "term": {
                                                        "movie": 46970 
                                                                    }
                                                }
                                  }
                      },
              "aggs": {
                      "most_popular": {
                                "terms": {
                                            "field": "movie", 
                                                    "size": 6
                                                              }
                                    }
                        }
}
'

