FROM mrrooijen/phoenix:latest

RUN apk update
RUN apk add vim

RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Set /app as workdir
WORKDIR /app

# disable ssl verify for git
RUN git config --system http.sslVerify false

# fetch magnetissimo
RUN git clone https://github.com/sergiotapia/magnetissimo.git /app

# install dependencies
RUN mix deps.get --force

ADD prod.secret.exs config/