FROM debian:sid
LABEL maintainer="faustin@mariadb.org"

ENV REPO https://github.com/mariadb/server
ENV BRANCH 10.5

RUN set -eux \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
      apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      devscripts \
      equivs \
      git \
      git-buildpackage \
      lintian \
      lsb-release \
      pristine-tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -eux \
    && git clone --single-branch --branch $BRANCH $REPO ./mariadb-server \
    && cd ./mariadb-server \
    && mk-build-deps -r -i debian/control \
      -t 'apt-get -y \
      -o Debug::pkgProblemResolver=yes \
      --no-install-recommends' \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && env DEB_BUILD_OPTIONS="parallel=2" debian/autobake-deb.sh \
    && cd .. \
    && lintian -EvIL +pedantic --color=always *.changes \
