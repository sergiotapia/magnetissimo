# Magnetissimo [![StackShare](http://img.shields.io/badge/tech-stack-0690fa.svg?style=flat)](http://stackshare.io/sergiotapia/magnetissimo) [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Web application that indexes all popular torrent sites, and saves it to the local database.

![alt tag](https://cloud.githubusercontent.com/assets/686715/22399059/7d02e772-e562-11e6-9c04-fb297bb9e109.png)

Goals:

* **No javascript**
* Crawl multiple index sites for torrents and magnet links.
* Run without ceremony. No pointless configuration needed.
* High performance, leveraging Elixir's GenServer and Erlang's BEAM VM.

# Community

Want to talk about Magnetissimo or suggest features? We have an official subreddit!

[http://reddit.com/r/magnetissimo](http://reddit.com/r/magnetissimo)

# Parser List

Magnetissimo currently fetches torrents from the following sites:

- [x] LimeTorrents
- [x] 1337x
- [x] Demonoid (disabled until Demonoid comes back online)
- [x] EZTV (thanks to @agustif)
- [x] ThePirateBay

# Usage Guide

Please check the Wiki pages for instructions on how to run Magnetissimo.

* [Running it locally](https://github.com/sergiotapia/magnetissimo/wiki/Usage:-Local)
* [Running it on Heroku](https://github.com/sergiotapia/magnetissimo/wiki/Usage:-Heroku)
* Running it on a VPS (to-do)
