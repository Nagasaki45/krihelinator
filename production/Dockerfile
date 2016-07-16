FROM mrrooijen/phoenix
RUN apk --no-cache add postgresql-client nodejs

ADD .. /cwd/

# Environment
ENV PORT 80
ENV MIX_ENV prod

# Setup dependencies, auto-acknowledge
RUN yes | mix deps.get --only prod
RUN yes | mix compile
RUN npm install

# Compile assets
RUN node_modules/brunch/bin/brunch build --production
RUN mix phoenix.digest

# Finally run the server
CMD mix phoenix.server
