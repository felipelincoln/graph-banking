FROM elixir:1.10.4-alpine AS build

# install ci dependencies
RUN apk add git

# setup app
WORKDIR /app
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY config config
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# copy builds to avoid recompiling
COPY priv priv
COPY lib lib
RUN cp -r _build/dev/ _build/test/
RUN cp -r _build/dev/ _build/prod/
RUN rm -rf _build/prod/graph_banking

# set build-time variables
ARG MIX_ENV

# compile
RUN mix do compile, release

# run server
CMD ["mix", "phx.server"]

# production stage
FROM alpine:3.11 AS production

RUN apk add openssl ncurses-libs
WORKDIR /app
ARG MIX_ENV
COPY --from=build /app/_build/$MIX_ENV/rel/graph_banking ./

CMD ["bin/graph_banking", "start"]
