curl -X PUT "192.168.1.34:9200/_snapshot/sigterms" -H 'Content-Type: application/json' -d'
{
        "type": "url",
                "settings": {
                            "url": "http://download.elastic.co/definitiveguide/sigterms_demo/"
                                    }
}
'
