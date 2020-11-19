FROM elixir:1.10.4-alpine

# install ci dependencies
RUN apk add git

# setup app
WORKDIR /app
ENV MIX_HOME=/root/.mix
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY config config
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# copy builds to avoid recompiling
COPY lib lib
RUN cp -r _build/dev/ _build/test/
RUN cp -r _build/dev/ _build/prod/
RUN rm -rf _build/prod/graph-banking

# set build-time variables
ARG MIX_ENV
ARG SECRET_KEY_BASE
ARG DATABASE_URL

# compile
RUN mix compile

# run server
CMD ["mix", "phx.server"]
