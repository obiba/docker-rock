# syntax=docker/dockerfile:1
#
# Rock R Server Dockerfile
#
# https://github.com/obiba/docker-rock
#

ARG R_VERSION=4.6.1

FROM rocker/r-ver:${R_VERSION} AS server

LABEL OBiBa=<dev@obiba.org>

ARG ROCK_VERSION=2.3.0
# set by docker build: amd64 or arm64
ARG TARGETARCH

ENV ROCK_VERSION=${ROCK_VERSION}
ENV ROCK_HOME=/srv
# Posit Package Manager serves prebuilt R packages for Ubuntu 24.04 (noble)
ENV ROCK_REPOS=https://p3m.dev/cran/__linux__/noble/latest
# accepted by the native executable, for compatibility with the JVM-based image
ENV JAVA_OPTS=-Xmx2G

WORKDIR /tmp

# Install Rock Server: native executable and the default config files not overridden in conf/
ADD --chmod=755 https://github.com/obiba/rock/releases/download/${ROCK_VERSION}/rock-${ROCK_VERSION}-linux-${TARGETARCH} /usr/share/rock/bin/rock
ADD --chmod=644 https://raw.githubusercontent.com/obiba/rock/${ROCK_VERSION}/src/dist/conf/logback.xml \
  https://raw.githubusercontent.com/obiba/rock/${ROCK_VERSION}/src/dist/conf/system.info.R \
  /usr/share/rock/conf/

COPY bin /opt/obiba/bin
COPY conf /usr/share/rock/conf
COPY scripts/install.mssql.bash .

RUN set -x && \
  groupadd --system --gid 10041 rock && \
  useradd --system --home /var/lib/rock --no-create-home --uid 10041 --gid rock rock && \
  chmod +x -R /opt/obiba/bin && \
  chown -R rock /opt/obiba && \
  mkdir -p /var/lib/rock/R/library && \
  # Additional system dependencies
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y gosu procps curl ca-certificates libsasl2-dev libssh-dev libjq-dev libgit2-dev libmariadb-dev libmariadb-dev-compat libpq-dev libsodium-dev libssh2-1-dev openssh-client cmake && \
  # Install MS SQL ODBC Driver
  ./install.mssql.bash && \
  rm -rf /var/lib/apt/lists/* install.mssql.bash && \
  # Install required R packages (--error: fail the build if a package fails to install; --skipmissing: suggested packages no longer on CRAN, e.g. RPresto, are skipped)
  install2.r --error -r https://www.rforge.net/ Rserve && \
  install2.r --error --skipmissing -l /var/lib/rock/R/library -r $ROCK_REPOS -d TRUE resourcer s3.resourcer odbc.resourcer && \
  install2.r --error -r $ROCK_REPOS arrow && \
  chown -R rock:rock /var/lib/rock && \
  chown -R rock:rock $ROCK_HOME

WORKDIR $ROCK_HOME
VOLUME $ROCK_HOME

EXPOSE 8085

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
