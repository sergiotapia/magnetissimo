FROM    bitwalker/alpine-elixir:1.5.2
ENV     MIX_ENV prod
EXPOSE  4000

RUN     apk add ca-certificates
COPY    ./ ./
RUN     mv config/prod.docker.exs config/prod.exs
RUN     mix do local.hex --force, deps.get --force, compile
USER default
