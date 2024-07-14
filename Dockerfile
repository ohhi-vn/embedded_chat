# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20240612-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.16.3-erlang-26.1.2-debian-bullseye-20240612-slim
#
ARG ELIXIR_VERSION=1.16.3
ARG OTP_VERSION=26.1.2
ARG DEBIAN_VERSION=bullseye-20240612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM --platform=linux/amd64 ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# Copy environment file and set environment variables
# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"
ENV ERL_FLAGS="+JPperf true"

ENV SECRET_KEY_BASE=4qlua0cPSKUF08Vn7kcETe7ikxYGuS0OLq8pcRXhItJ1Rd+XvFxNMIskzoe5AqUz
ENV HOST=chat.vn
ENV PHX_HOST=chat.vn
ENV PHX_HTTP_PORT=8080
ENV PHX_HTTPS_PORT=443
ENV DATABASE_FILE="/data/chat_service_dev.db"

# install mix dependencies
COPY mix.exs mix.lock ./

RUN mix deps.clean --all
RUN HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120  mix deps.get --only $MIX_ENV
RUN mkdir config

EXPOSE 443 8080

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY entrypoint.sh /app/entrypoint.sh

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel

RUN mix ecto.drop
RUN mix ecto.create

# RUN mix ecto.gen.migration "create_room_table_v1"
# RUN ls priv/repo/migrations
RUN mix ecto.migrate

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/chat_service ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]
ENV PHX_SERVER=true

CMD ["/app/bin/chat_service", "start"]