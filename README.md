# Magnetissimo

![https://i.imgur.com/J6eB3mp.png](https://i.imgur.com/J6eB3mp.png)

Magnetissimo is a self-hosted web application that indexes all
popular torrent sites and saves the magnet links to your local
database.

![image](https://user-images.githubusercontent.com/686715/231510383-cc0e8f00-0cf7-4990-8933-4185a69e4f0e.png)

![image](https://user-images.githubusercontent.com/686715/231512138-879737fc-02a9-43d0-a609-292a4fae6b2b.png)

### Goals:

- **No javascript**
- Crawl multiple index sites for torrents and magnet links.
- Easily integrates with both [Sonarr](https://github.com/Sonarr/Sonarr) and [Radarr](https://github.com/Radarr/Radarr).
- Run without ceremony. No need for configurations.
- Easy to understand source code. Special care is taken to keep code lean and understandable.
- High performance, leveraging Elixir's GenServer and Erlang's BEAM VM.

### Usage Guide:

TBD - We need to write some easy to follow guides here. HELP WANTED!

We want to explain how to run Magnetissimo on:

- Windows
- Linux
- Mac

### API

All endpoints returns JSON formatted information.

`/search` endpoint: http://localhost:4000/api/search/:search_term

Search returns torrents that match the `search_term` param.

`/latest` endpoint: http://localhost:4000/api/latest

Latest returns the latest 50 published_at torrents.

### Contributing:

We have a `.tool-versions` so you can use ASDF to install the right versions
really easily.

```
elixir 1.14.4
nodejs 19.8.1
```

Then `asdf install`.

You also need to have Postgres running and configure it using the `DATABASE_URL`
environment variable.

Finally set up your database with some dummy data and run the project.

```bash
mix deps.get
mix ecto.reset
iex -S mix phx.server
```

### Community

Want to talk about Magnetissimo or suggest features? We have an official Discord server.

[Click to join our official Discord server](https://discord.gg/CFtGUaW)
