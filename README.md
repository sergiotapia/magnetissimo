# Magnetissimo

![https://i.imgur.com/J6eB3mp.png](https://i.imgur.com/J6eB3mp.png)

Magnetissimo is a self-hosted web application that indexes all
popular torrent sites and saves the magnet links to a sqlite database
file.

![image](https://user-images.githubusercontent.com/686715/231510383-cc0e8f00-0cf7-4990-8933-4185a69e4f0e.png)

![image](https://user-images.githubusercontent.com/686715/231512138-879737fc-02a9-43d0-a609-292a4fae6b2b.png)

### Goals:

- **No javascript**
- Database is a single sqlite file.
- Crawl multiple index sites for torrents and magnet links.
- Easily integrates with both [Sonarr](https://github.com/Sonarr/Sonarr) and [Radarr](https://github.com/Radarr/Radarr).
- No config needed, it just runs.
- Easy to understand source code. Special care is taken to keep code lean and understandable.
- Low resource usage.

### Usage Guide:

We want to explain how to run Magnetissimo on:

- Windows
- Linux
- Mac

**Docker Compose**

```
# Generate a secret_key with either
openssl rand -base64 64
mix phx.gen.secret

# Enter that key as SECRET_KEY_BASE in the docker-compse.yml file
SECRET_KEY_BASE=YourKeyGoesHere

# Start the application
docker compose up -d
```

If you are going to access Magnetissimo at an address besides `localhost`, add `PHX_HOST` to your environment variables. For example, to access it at `http://192.168.0.54:4000`:

```
      - PHX_HOST=192.168.0.54
```

Or to access it at `https://magnetissimo.domain.tld`:

```
      - PHX_HOST=magnetissimo.domain.tld
```

**Kubernetes**

```
# Generate a secret_key with either
openssl rand -base64 64
mix phx.gen.secret

Edit the k8s/deployment.yaml file, and replace the ENV SECRET_KEY_BASE with your generated key.
Edit k8s/ingress.yaml & the PHX_HOST in k8s/deployment.yaml and replace the host with your domain name.

The Postgres database is configured to use the DNS name assuming it is being deployed to the default namespace, update this in the enviroment variables if you are deploying to a different namespace.

Finaly, deploy the application to your cluster.
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/svc.yaml
kubectl apply -f k8s/ingress.yaml
```

**Local Development**

```
asdf install
mix deps.get
iex -S mix phx.server
```

Then visit: http://localhost:4000

### API

All endpoints returns JSON formatted information.

`/search` endpoint: http://localhost:4000/api/search/:search_term

Search returns torrents that match the `search_term` param.

`/latest` endpoint: http://localhost:4000/api/latest

Latest returns the latest 50 published_at torrents.

### Contributing:

We have a `.tool-versions` so you can use ASDF to install the right versions
really easily.

Just run `asdf install` from the root of the project and you will install all
the deps necessary.

The reset your sqlite database and seed it with one single command:

```bash
# Grab Elixir deps!
mix deps.get

# Reset that BD!
mix ecto.reset

# Run the app in local dev mode.
iex -S mix phx.server
```

### Community

Want to talk about Magnetissimo or suggest features? We have an official Discord server.

[Click to join our official Discord server](https://discord.gg/CFtGUaW)
