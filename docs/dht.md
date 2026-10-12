# The DHT crawler

The BitTorrent DHT (Mainline DHT, [BEP 5]) is a Kademlia network of millions
of peers. It maps a torrent's infohash to the peers sharing it, and holds
nothing else: no names, no files, no search. Switched on at `/dht`,
Magnetissimo walks it in the background and indexes what it finds. It is the
one source not asked at search time (see "Decisions worth knowing" in
`CONTRIBUTING.md`), and it is off until someone switches it on.

The switch and the rate slider on `/dht` save a row in `dht_settings`
(`DHT.Settings`). `DHT.update_settings/1` writes it and hands it to
`DHT.Runner`, which is always running: it starts `DHT.Crawler`, stops it, or
restarts it at the new rate. On a stop the sampler saves the nodes it knows
and the indexer writes what is waiting, so a restart resumes in seconds.
There is no login, so anyone who can open the page can flip the switch.
`DHT_PORT` is the one env var: the local UDP port, any free one by
default.

The code is `lib/magnetissimo/dht/`, and every module's moduledoc says why it
works the way it does. This page covers the protocol, what a home network
sees, and the measurements behind the three rate presets.

## How a torrent is found

1. **Sample** ([BEP 51]). `Sampler` asks each node it knows for
   `sample_infohashes`: up to 20 of the infohashes the node stores, plus
   other nodes to ask next. It honours the `interval` each node asks for, and
   never asks a node again sooner than five minutes. It starts from the
   nodes it saved last time (`dht_nodes`), or from the public bootstrap
   routers.
2. **Triage.** `Fetcher` keeps eight hashes of each sample, at random,
   then drops hashes it saw recently (two generations of 200,000) and
   hashes already in the index (one query every half second). The rest wait
   newest first, and only one job runs per node at a time: a node asked for
   the peers of twenty hashes in a second stops answering (libtorrent cuts
   off at about five packets a second per IP).
3. **Peers** ([BEP 5]). `get_peers` to the node that sampled the hash, which
   stores its peers, and one hop on to the closer nodes it names if it has
   none.
4. **Metadata** ([BEP 3], [BEP 10], [BEP 9]). `Metadata` and `PeerWire` open
   TCP to up to three peers at a time, do the BitTorrent and extension
   handshakes, and download the info dictionary in 16 KiB pieces. The pieces
   must hash (SHA-1) to the infohash. The first peer to deliver wins.
5. **Read and file.** `Info` reads the name, size and files. Private torrents
   ([BEP 27]), torrents under 1 KiB or over a pebibyte, and names with NUL
   bytes are refused.
   `Classifier` picks a Torznab category from file extensions weighed by
   size and from the name, and refuses anything matching the banned
   keywords (child sexual abuse material). The keyword lists started from
   bitmagnet's. A site that later returns the same torrent replaces the
   guess with its own category. After the classifier changes,
   `Magnetissimo.Release.reclassify_dht()` (from `bin/magnetissimo eval`,
   or `mix run --no-start -e` in development) files the DHT's torrents
   again; `classifier_corpus_test.exs` holds real torrents a person
   labelled, to catch a change that files them wrongly.
6. **Index.** `Indexer` writes batches through `Torrents.index_torrents/2`
   and broadcasts them to the `/dht` page.
7. **Swarm** ([BEP 33]). `get_peers` with `scrape: 1` to the nodes that
   answered returns two bloom filters, one over seeders' IPs and one over
   downloaders'. ORed together they estimate both counts. The last hundred
   torrents are scraped again every ten minutes.

The crawler is a read-only node ([BEP 43], `ro: 1`). Nobody adds it to a
routing table or sends it queries, so it needs no open or forwarded port,
and works from behind NAT or inside Docker as is.

## What a home router sees

A crawler's bandwidth is small. What hurts a household is the router's
**connection-tracking table** (conntrack, the NAT table). Every distinct
remote address the crawler talks to is an entry:

- about 30 seconds for UDP that got no answer, and 120 to 180 seconds for
  UDP that did;
- 120 seconds for a TCP connect that got no answer, and seconds for one we
  reset.

Consumer routers hold 4,000 to 16,000 entries, and better ones 64,000. When
the table fills, new connections are dropped, including everyone's DNS and
web traffic. bitmagnet users report exactly this
([#299](https://github.com/bitmagnet-io/bitmagnet/issues/299),
[#348](https://github.com/bitmagnet-io/bitmagnet/issues/348)): gigabit fiber
crawling to a halt at under 100 kB/s, with 15,000 to 20,000 entries.

So the crawler:

- sends every UDP packet through one token bucket (`Node`), every query kind
  counted, at most `rate` a second;
- caps TCP fetches at `fetches` at once, each trying at most three peers at a
  time, and closes every connection with a reset (`linger: {true, 0}`);
- **stops sampling while the fetch queue holds `fetches × 25` hashes.** One
  sample answer holds up to 20 hashes, and a fetch takes seconds, so
  unchecked it finds hashes thousands of times faster than it can fetch
  them. Every packet spent on that would be a table entry for nothing. The
  rate is a ceiling, and the crawler mostly runs well under it;
- shows its router load on `/dht`: the distinct addresses it sent to in the
  last two minutes. That count is an upper bound, since unanswered UDP
  entries expire after 30 seconds.

## The presets, measured

Measured on 2026-10-12 on a home connection: a Linux desktop wired to an
AT&T gateway, five minutes per preset, twice: once on an early build and
once on the final one. The desktop runs `nf_conntrack` with Linux's default
timeouts (UDP 30 s and 120 s, TCP SYN_SENT 120 s), which are the ones
OpenWrt and most Linux-based routers use, so its `nf_conntrack_count` is
what the crawler would add to such a router's table. Every 10 seconds a
script recorded that count and the ping to the gateway and to 1.1.1.1 (5
pings each). "Steady" is the second half of each run, measured against a
30-second baseline with the crawler off. The scripts were throwaway and are
not in the repo.

| Rate | Ceiling | Packets/s, average | Bandwidth out / in | Router entries added, steady average (peak) | Ping to gateway / internet, no loss in any run | Torrents indexed |
| --- | --- | --- | --- | --- | --- | --- |
| `gentle` (default) | 20 pkt/s, 8 fetches | 8 to 9 | 8–11 / 25–27 kbit/s | +590 (+880)¹ | 0.6 / 4.3–4.4 ms | 14–16 a minute, ~900 an hour |
| `normal` | 75 pkt/s, 24 fetches | 29 | 34–37 / 83–84 kbit/s | +1,800 to +2,160 (+2,520 to +2,920) | 0.7–0.8 / 4.5–6.3 ms | 41–44 a minute, ~2,600 an hour |
| `max` | 250 pkt/s, 64 fetches | 85–94 | 100–112 / 220–293 kbit/s | +5,800 to +7,000 (+7,800 to +8,950) | 0.8 / 4.7–4.8 ms | 111–129 a minute, ~7,000 an hour |

¹ The second `gentle` run's baseline swung between 400 and 800 as other
programs on the desktop opened connections, so only the first run's count is
quoted. Its crawler-side counters matched the first run's.

The baseline was 0.5 to 0.8 ms to the gateway and 4.3 to 4.6 ms to
1.1.1.1. No preset moved latency in a way a person would notice; the worst
single sample was 11.7 ms to 1.1.1.1, under `normal`. This gateway's table
holds all three, but on a router with a 4,000-entry table:

- `gentle` uses about a fifth of it, and is the default;
- `normal` uses about half, which leaves room for a household;
- `max` overflows it. Use it on a VPS, behind a VPN container, or on a
  router whose table holds 16,000 or more.

The `/dht` page shows each stop's average, peak and yield under the slider
(`DHT.presets/0`).

What decides the yield is fetching, not discovery. At every preset, about
one hash in eleven fetched turned into a torrent:

- 30 to 37% have no peers the DHT knows of (dead torrents);
- 42 to 46% have peers, but none hand over the metadata. Most peers don't
  answer at all (behind NAT, or gone). Others refuse, close on us (some
  require encryption, which isn't implemented), or don't have the metadata
  themselves;
- 9 to 12% time out at the `get_peers` step.

For comparison, bitmagnet's default (`scaling_factor` 10) reports 100 to
1,000 torrents a minute, from far more connections: its users see 15,000 to
20,000 table entries. magnetico's default `--max-rps` of 500 caps only
some of its packets.

## If browsing slows down

- Slide the rate down to `gentle`.
- Route the container through a VPN. Docker with
  [gluetun](https://github.com/qdm12/gluetun), as bitmagnet's compose file
  does, makes the router see one connection. A VPN also hides your IP from the
  swarms the crawler fetches metadata from.
- Put the server on its own VLAN, or on a VPS.
- On OpenWrt, raise `net.netfilter.nf_conntrack_max` and lower
  `nf_conntrack_udp_timeout_stream`.

## Being seen

Fetching metadata is a real BitTorrent connection. The peers in a swarm, and
anyone monitoring it, see your IP make a handshake for that torrent, though
no content is downloaded. bitmagnet recommends a VPN for the same reason.
The DHT carries everything people share, so expect adult material (filed
under XXX) and worse (refused by the banned keywords).

## Not done yet

- **Encryption (MSE/PE).** Peers that insist on it close on us.
  Supporting it would raise the success rate.
- **IPv6** (`nodes6`, BEP 32) and **BEP 42** secure node ids. Neither is
  needed by a read-only node today.

[BEP 3]: https://www.bittorrent.org/beps/bep_0003.html
[BEP 5]: https://www.bittorrent.org/beps/bep_0005.html
[BEP 9]: https://www.bittorrent.org/beps/bep_0009.html
[BEP 10]: https://www.bittorrent.org/beps/bep_0010.html
[BEP 27]: https://www.bittorrent.org/beps/bep_0027.html
[BEP 33]: https://www.bittorrent.org/beps/bep_0033.html
[BEP 43]: https://www.bittorrent.org/beps/bep_0043.html
[BEP 51]: https://www.bittorrent.org/beps/bep_0051.html
