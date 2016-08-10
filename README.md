# Magnetissimo

Web application that indexes all popular torrent sites, and saves it to the local database.

![alt tag](http://i.imgur.com/LzzWlk0.png)

Goals:

* Crawl multiple index sites for torrents and magnet links.
* Run without ceremony. No pointless configuration needed.
* High performance, leveraging Elixir's GenServer and Erlang's BEAM VM.
* Unit tested for correctness.

# Run it locally

You need a few things locally for the project to run:

  * Elixir (At least version 1.3)
  * Erlang
  * PostgreSQL
  * Redis
  * Node

To start Magnetissimo locally:

  * Install dependencies with `mix deps.get`
  * Edit `dev.exs` and set your database username and password (see example below).
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

```
# Configure your database - dev.exs
config :magnetissimo, Magnetissimo.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "magnetissimo_dev",
  hostname: "localhost",
  pool_size: 10

# Configure your redis - config/config.exs
config :exq,
  host: System.get_env("REDIS_HOST") || "127.0.0.1",
  port: String.to_integer(System.get_env("REDIS_PORT") || "6379"),
  username: "admin",
  password: "admin",
  namespace: "exq",
  queues: [
    {"thepiratebay", 15},
    {"demonoid", 15}, 
    {"isohunt", 15},
    {"limetorrents", 15},
    {"torrentdownloads", 15}
  ]
```

# Run it on Heroku

To run it on Heroku, you need to:

Create the Heroku application using the Elixir build pack.

```
$ heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
Creating mysterious-meadow-6277... done, stack is cedar-14
Buildpack set. Next release on mysterious-meadow-6277 will use https://github.com/HashNuke/heroku-buildpack-elixir.git.
https://mysterious-meadow-6277.herokuapp.com/ | https://git.heroku.com/mysterious-meadow-6277.git
Git remote heroku added
```

Add the Phoenix static buildpack to the same Heroku project.

```
$ heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
```

Generate a secret key for the project:

```
$ mix phoenix.gen.secret
xvafzY4y01jYuzLm3ecJqo008dVnU3CN4f+MamNd1Zue4pXvfvUjbiXT8akaIF53
```

Add the following environment variables, including the previously generated key:

```
POOL_SIZE=18
DATABASE_URL=foobarbaz
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
SECRET_KEY_BASE=xvafzY4y01jYuzLm3ecJqo008dVnU3CN4f+MamNd1Zue4pXvfvUjbiXT8akaIF53
```