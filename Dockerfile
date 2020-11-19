FROM elixir:1.10.4-alpine

# install ci dependencies
RUN apk add git

WORKDIR /app
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY config config
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# set build-time env variable
ARG MIX_ENV

# compile and build
COPY lib lib
RUN mix compile

# make a copy of dev deps into test deps
RUN cp -r _build/dev/ _build/test/

CMD ["mix", "phx.server"]
