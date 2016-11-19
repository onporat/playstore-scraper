# Playstore Scraper exercise
This project is has to two subprojects client and server.

The client is developed in golang, it reads playstore apps ID's sends them to the server for scrapping.

The server is developed in Haskell, it receives IDs from the client via simple HTTP post commands, scrap results are stored in apps.json

apps.json is written in the root directory of the server. The file is in Line delimited JSON format i.e. record per line.


## Server structure overview:
There are four (blocking) queues and three type of workers that move jobs from queue to queue.

### Init
- Put 50 dummy proxies in the freshProxyQ
- Start 4 scraping workers (one per core)
- Start 1 resting worker
- Start 1 output worker

New jobs (app IDs) are sent to the web server via HTTP-POST, the server puts the AppId in the appIdQ

### Scrap workers
- Takes AppId from the appIdQ and fresh proxy from the freshProxyQ
- call the scraper with AppId and proxy address
- Puts the used proxy in the tiredProxyQ to let it rest
- Puts the AppMeta from the scrapper in the outputQ

### Resting proxy worker
- Takes proxy from the tiredProxyQ
- Checks if the proxy needs some sleep
- If so rest
- Put the proxy back in the freshProxyQ

### Output worker
- Takes scraped apps from the outputQ and append them to apps.json

### Setup
Follow README files in the client and server directories for build and execute instructions.

### Test
Download html of one app page and start local http server
```
cd server/test/
wget -O GooglePlay.html 'https://play.google.com/store/apps/details?id=com.bigduckgames.flow&hl=en'
python -m SimpleHTTPServer 9000
```
edit the scraper code to fetch apps from the local server
start the server
run the client and send jobs to the server
watch times in the access log (on screen) of the local http server 

Send jobs to the server using curl
```
dos2unix IDs.txt
cat IDs.txt | xargs -I{} curl -d id={} 0:8000/write
```
