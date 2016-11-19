# Playstore Scraper

## Business Context:
We want to scrape data about certain Android apps from a list of package names we got.

## Requirements:
- You need to create a service that gets an package name, and retrieves the app&#39;s title, icon and developer email from its app page (If it exists). This service can be written in any language you wish.
- You will be supplied with a list of playstore app IDs. You need to create a small utility in **Golang** that can read this list from a file, and send each ID to the service you&#39;ve written.
- In order to evade bot detection, the service needs to use different proxies - you can create a list of 50 imaginary IPs of proxies to use. Each request should use a different proxy IP (methodically - you can assign an IP to each request without really using it)
- Make sure that each proxy IP will not be used more than once every 10 seconds.
- Perform the scraping as fast as possible with these restraints.
- The data for each app can be saved to any output you wish, as long as we can run it independently on our premise.

## Architecture:
- You should create an architecture that is efficient, sufficient and simple to use
- You can add any other technology of your choosing

## What should you send us:
- **Private** git repo (in bitbucket.org for example)
- A short guide on how to **setup** the project and how to **test** it
- A short overview of the solution you chose


