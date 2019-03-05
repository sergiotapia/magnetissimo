# Magnetissimo

Magnetissimo is a self-hosted web application that indexes all popular torrent sites.

![A screenshot of Magnetissimo](https://i.imgur.com/ecI45aE.png)

### Goals

- **No javascript**
- Crawl multiple index sites for torrents and magnet links.
- Easily integrates with both [Sonarr](https://github.com/Sonarr/Sonarr) and [Radarr](https://github.com/Radarr/Radarr).
- Run without ceremony. No need for configurations.
- Easy to understand source code. Special care is taken to keep code lean and understandable.
- High performance, leveraging Elixir's GenServer and Erlang's BEAM VM.

On average the application uses about 120MB of RAM:

![https://i.imgur.com/3QfChzk.png](https://i.imgur.com/3QfChzk.png)

We work closely with other providers and search engines to be respectful of their hardware and minimize our impact to their systems.

If you'd like us to add you to our supported vendors list, please drop us a Github Issue.

### Usage Guide

Magnetissimo was designed to be easy to run.

It's been tested on:

- Erlang/OTP 21
- Elixir 1.8.0

We have guide written for you:

- [Running it locally](https://github.com/sergiotapia/magnetissimo/wiki/Usage:-Local)
- Running it on a VPS (to-do)
- Running it on Heroku (to-do)

### Community

Want to talk about Magnetissimo or suggest features? We have an official Discord server.

[Click to join](https://discord.gg/CFtGUaW)

### Supported websites

The following websites are fully supported.

- 1337x.to
- The Pirate Bay
- YTS.am
- Nyaa
- Nyaa Pantsu
- EZTV
- TorrentDownloads
