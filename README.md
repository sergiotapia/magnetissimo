# Work in progress, but so nearly there!

- Crawler is working and performing really well. 1000 torrents added per minute.
- Tests are written.

We need:

- Functional search
- Run a performance load test
- Write usage documentation

![alt tag](http://i.imgur.com/t9F5lZl.png)

# Magnetissimo

To start Magnetissimo:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# How it works

Magnetissimo has different torrent site indexers that run on GenServer. Each
will process a site asynchronously and save the torrents it's find in the
database.

Visit the home page and you'll see a paginated collection of torrents you can
use.

**There is no configuration needed**.

It'll just do it's thing and serve up torrents so fast your hard drive will
explode.
