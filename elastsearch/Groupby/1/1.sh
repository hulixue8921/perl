curl -X POST "http://192.168.1.34:9200/_reindex" -H 'Content-Type: application/json' -d'
{

      "source": {
              "index": "mlratings"
                    },
            "dest": {
                    "index": "test",
                        "op_type": "create"
                              }
}'
