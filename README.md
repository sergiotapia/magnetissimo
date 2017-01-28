# Magnetissimo [![StackShare](http://img.shields.io/badge/tech-stack-0690fa.svg?style=flat)](http://stackshare.io/sergiotapia/magnetissimo)

Web application that indexes all popular torrent sites, and saves it to the local database.

![alt tag](http://i.imgur.com/O6qoRDG.png)

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

# Building Docker Container

Download postgres docker images `docker pull postgres` and create a database by logging into the postgresql container

    docker pull postgresql
    docker run -d --name postgresql -p 5432:5432 postgres

    # ssh into postgresql container
    docker exec -it postgresql bash

    # login to psql shell
    psql -U postgres

    # Create a database
    create database tracker;
    \q

    exit

Now build the docker image

    cd docker

    docker build -t magnetissimo:latest .

    docker run -p 4000:4000 --name magnetissimo magnetissimo


