FROM bitwalker/alpine-elixir-phoenix:1.4.0

# Cache elixir deps
ADD mix.exs mix.lock ./
# Always compile into _build/prod
RUN MIX_ENV=prod mix do deps.get, deps.compile

# Add the source code
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY web ./web

# Compile the krihelinator (again, to _build/prod)
RUN MIX_ENV=prod mix compile

# Finally run the server
CMD mix phoenix.server
