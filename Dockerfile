FROM bitwalker/alpine-elixir-phoenix:latest

# Probably missing from the original image...
RUN apk --no-cache add erlang-eunit

ADD . .

# Environment
ENV PORT 80
ENV MIX_ENV prod

# Setup dependencies, auto-acknowledge
RUN mix deps.get --only prod
RUN mix compile
RUN npm install

# Compile assets
RUN brunch build --production
RUN mix phoenix.digest

# Finally run the server
CMD mix phoenix.server
