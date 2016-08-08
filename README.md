# Work in progress, but so nearly there!

- Crawler is working and performing really well. 13000 torrents added per minute.
- Tests are written.
- Search is functional and super fast.

We need:

- Run a performance load test
- Write usage documentation

![alt tag](http://i.imgur.com/LzzWlk0.png)

# Run it locally

You need a few things locally for the project to run:

  * Elixir (At least version 1.3)
  * Erlang
  * PostgreSQL
  * Redis
  * Node

To start Magnetissimo locally:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

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

Add the following environment variables:

```
POOL_SIZE=18
DATABASE_URL=foobarbaz
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
$ mix phoenix.gen.secret
xvafzY4y01jYuzLm3ecJqo008dVnU3CN4f+MamNd1Zue4pXvfvUjbiXT8akaIF53
SECRET_KEY_BASE=xvafzY4y01jYuzLm3ecJqo008dVnU3CN4f+MamNd1Zue4pXvfvUjbiXT8akaIF53
```

# How it works

Magnetissimo is automatically configured to start crawling torrent sites
as soon as it's started. You should see torrents being added at a very high rate
and visible on the sites home page.

Just visit http://localhost:4000 to see all the torrents indexed so far.

No configuration need on your end.