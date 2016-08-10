# Magnetissimo

Web application that indexes all popular torrent sites, and saves it to the local database.

![alt tag](http://i.imgur.com/meqeZrc.png)

Goals:

* Crawl multiple index sites for torrents and magnet links.
* Run without ceremony. No pointless configuration needed.
* High performance, leveraging Elixir's GenServer and Erlang's BEAM VM.
* Unit tested for correctness.

# Community

Want to talk about Magnetissimo or suggest features? We have an official subreddit!

[http://reddit.com/r/magnetissimo](http://reddit.com/r/magnetissimo)

# Parser List

Magnetissimo currently fetches torrents from the following sites:

- [x] Demonoid
- [x] Isohunt
- [x] LimeTorrents
- [x] ThePirateBay
- [x] TorrentDownloads
- [x] https://1337x.to/
- [ ] https://torrentproject.se
- [ ] https://rarbg.to/torrents.php
- [ ] https://www.torlock.com/
- [ ] http://www.seedpeer.eu/
- [ ] http://sectorrent.com/
- [ ] http://www.torrenthound.com/
- [ ] http://piratepublic.com
- [ ] bitsnoop.com
- [ ] extratorrent.cc
- [ ] linuxtracker.org
- [ ] monova.org
- [ ] newtorrents.info
- [ ] torrentbit.net
- [ ] torrentfunk.com
- [ ] torrentreactor.com
- [ ] torrents.net
- [ ] yourbittorrent.com

# Usage Guide

Please check the Wiki pages for instructions on how to run Magnetissimo.

* [Running it locally](https://github.com/sergiotapia/magnetissimo/wiki/Usage:-Local)
* [Running it on Heroku](https://github.com/sergiotapia/magnetissimo/wiki/Usage:-Heroku)
* Running it on a VPS (to-do)