# Playstore scraper server

Install [stack](https://docs.haskellstack.org/en/stable/README/)

###Build and execute
```
stack build

stack exec playstore-parser-exe
```

###Post job to the server
```
curl -d id=com.example.app 0:8000/write
```

scrap resules written to apps.json
