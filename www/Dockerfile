FROM elixir:1.5.2

RUN apt-get update && apt-get install -y inotify-tools

WORKDIR /home/elixir/app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod
COPY mix.exs ./
COPY mix.lock ./
RUN mix do deps.get, deps.compile

COPY . ./

CMD ["mix", "phoenix.server"]
