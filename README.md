# Magnetissimo [![StackShare](https://img.shields.io/badge/tech-stack-0690fa.svg?style=flat)](https://stackshare.io/sergiotapia/magnetissimo)

Web application that indexes all popular torrent sites, and saves it to the local database.

![alt tag](https://cloud.githubusercontent.com/assets/686715/22401811/388e3b3e-e5b0-11e6-9429-aca85f3ce0b6.png)

Goals:

* **No javascript**
* Crawl multiple index sites for torrents and magnet links.
* Run without ceremony. No pointless configuration needed.
* High performance, leveraging Elixir's GenServer and Erlang's BEAM VM.

# Usage Guide

Please check the Wiki pages for instructions on how to run Magnetissimo.

* [Running it locally](https://github.com/sergiotapia/magnetissimo/wiki/Usage:-Local)
* Running it on a VPS (to-do)

You can also run the project on Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

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
- [x] TorrentDownloads
- [x] WorldWide Torrents
