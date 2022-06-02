# ---- Build Stage ----
FROM bitwalker/alpine-elixir-phoenix:latest as build

# install build dependencies
ENV MIX_ENV=prod

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Bitwalker's Alpine Elixir image has prepared this directory for us, so we shouldn't need to mkdir
WORKDIR /app

# copy over necessary config files
COPY config/ /app/config/
COPY mix.exs /app/
COPY mix.* /app/

COPY apps/db/mix.exs /app/apps/db/
COPY apps/messaging/mix.exs /app/apps/messaging/
COPY apps/web/mix.exs /app/apps/web/

RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . /app/

WORKDIR /app/apps/web
RUN MIX_ENV=prod mix compile
# RUN npm install --prefix ./assets
# RUN npm run deploy --prefix ./assets
RUN mix phx.digest
RUN mix phx.gen.secret

WORKDIR /app
RUN MIX_ENV=prod mix release

# ---- Application Stage ----
FROM bitwalker/alpine-elixir:latest

# install runtime dependencies
RUN apk add --update bash openssl postgresql-client

ENV PORT=4001 \
    MIX_ENV=prod \
    SHELL=/bin/bash

# prepare app directory
WORKDIR /app

# copy release to app container
COPY --from=build app/_build/prod/rel/release_name .
COPY entrypoint.sh .
COPY /apps/web/priv/cert/privkey.pem privkey.pem
COPY /apps/web/priv/cert/fullchain.pem fullchain.pem
RUN chmod -R 0754 /app

ENV HOME=/app
CMD ["bash", "/app/entrypoint.sh"]