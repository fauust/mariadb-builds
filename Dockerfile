FROM debian:sid
LABEL maintainer="faustin@mariadb.org"

ENV DEBIAN_FRONTEND noninteractive
ENV REPO https://github.com/mariadb/server
ENV BRANCH 10.5

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential \
    ca-certificates curl devscripts equivs git git-buildpackage \
    lsb-release pristine-tar vim time lintian

RUN git clone --single-branch --branch $BRANCH $REPO ./mariadb-server && \
    cd ./mariadb-server && \
    mk-build-deps -r -i debian/control -t 'apt-get -y -o Debug::pkgProblemResolver=yes \
      --no-install-recommends' && \
    time env DEB_BUILD_OPTIONS="nocheck" debian/autobake-deb.sh && \
    cd .. && \
    lintian -EvIL +pedantic --color=always *.changes
