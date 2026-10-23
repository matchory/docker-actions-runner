# syntax=docker/dockerfile:1
FROM ghcr.io/actions/actions-runner:2.338.0@sha256:4ffadc0002b2581327e06101fc8c06cd189232baf79fe561fac9caeb76f5e807

# Must match the php-version our workflows pass to shivammathur/setup-php. When it
# finds this version already installed it skips its own install, which otherwise
# costs every job about a minute.
ARG PHP_VERSION="8.5"

USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    set -eux

    export DEBIAN_FRONTEND=noninteractive
    rm -f /etc/apt/apt.conf.d/docker-clean

    apt-get update
    apt-get install --yes --no-install-recommends ca-certificates curl gnupg

    # The PHP builds setup-php itself installs on self-hosted runners.
    curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6' \
      | gpg --dearmor --output /etc/apt/keyrings/ondrej-php.gpg
    echo "deb [signed-by=/etc/apt/keyrings/ondrej-php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" \
      > /etc/apt/sources.list.d/ondrej-php.list

    apt-get update
    # The upstream image lags the Ubuntu security archive between its releases.
    apt-get upgrade --yes

    # The tools GitHub's hosted images ship and our workflows rely on: psql loads the
    # webapp's schema baseline, and the pnpm binary links against libatomic.
    apt-get install --yes --no-install-recommends \
      postgresql-client \
      libatomic1 \
    ;

    # Everything setup-php installs on a self-hosted runner (its self_hosted_helper
    # and configs/php_packages), so it finds the packages present and moves on. Its
    # opcache package is left out: PHP 8.5 builds OPcache into the core.
    apt-get install --yes --no-install-recommends \
      apt-transport-https \
      autoconf \
      automake \
      file \
      g++ \
      gcc \
      jq \
      make \
      unzip \
      "php${PHP_VERSION}-cgi" \
      "php${PHP_VERSION}-cli" \
      "php${PHP_VERSION}-curl" \
      "php${PHP_VERSION}-dev" \
      "php${PHP_VERSION}-fpm" \
      "php${PHP_VERSION}-intl" \
      "php${PHP_VERSION}-mbstring" \
      "php${PHP_VERSION}-mysql" \
      "php${PHP_VERSION}-pgsql" \
      "php${PHP_VERSION}-xml" \
      "php${PHP_VERSION}-zip" \
    ;
EOF

USER runner
