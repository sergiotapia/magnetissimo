FROM ubuntu:16.04

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y wget && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get -y install esl-erlang && \
    apt-get -y install elixir && \
    apt-get -y install git

RUN git clone https://github.com/sergiotapia/magnetissimo /magnetissimo

ADD dev.exs /magnetissimo/config/dev.exs

RUN cd /magnetissimo && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --force && \
    mix ecto.create --force && \
    mix ecto.migrate --force

RUN wget https://deb.nodesource.com/setup_6.x && \
    bash setup_6.x && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get install -y build-essential

RUN cd /magnetissimo && \
    npm install

EXPOSE 4000

CMD cd /magnetissimo && mix phoenix.server
