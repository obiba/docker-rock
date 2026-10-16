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

ENV ROCK_VERSION=${ROCK_VERSION}
ENV ROCK_HOME=/srv
# Posit Package Manager serves prebuilt R packages for Ubuntu 24.04 (noble)
ENV ROCK_REPOS=https://p3m.dev/cran/__linux__/noble/latest
ENV JAVA_OPTS="-Xmx1G -XX:+UseG1GC"
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Eclipse Temurin JRE, as in the former eclipse-temurin based image
COPY --from=eclipse-temurin:25-jre-resolute $JAVA_HOME $JAVA_HOME

WORKDIR /tmp

# Install Rock Server distribution, its default config files overridden by conf/
ADD https://github.com/obiba/rock/releases/download/${ROCK_VERSION}/rock-${ROCK_VERSION}-dist.zip rock.zip
RUN unzip -q rock.zip -d /usr/share && \
  mv /usr/share/rock-${ROCK_VERSION} /usr/share/rock && \
  chmod +x /usr/share/rock/bin/rock && \
  rm rock.zip

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
  DEBIAN_FRONTEND=noninteractive apt-get install -y gosu procps curl ca-certificates libsasl2-dev libssh-dev libjq-dev libgit2-dev libmariadb-dev libmariadb-dev-compat libpq-dev libsodium-dev libssh2-1-dev openssh-client cmake \
    libcurl4-openssl-dev libssl-dev libxml2-dev libcairo2-dev freeglut3-dev pandoc cargo libmagick++-dev libharfbuzz-dev libfribidi-dev libv8-dev && \
  # Install MS SQL ODBC Driver
  ./install.mssql.bash && \
  rm -rf /var/lib/apt/lists/* install.mssql.bash && \
  # Install required R packages (--error: fail the build if a package fails to install; --skipmissing: suggested packages no longer on CRAN, e.g. RPresto, are skipped)
  install2.r --error -r https://www.rforge.net/ Rserve unixtools && \
  # Packages of the former obiba/obiba-r base image
  install2.r --error --skipmissing -r $ROCK_REPOS -d TRUE opalr BiocManager devtools tidyverse knitr rmarkdown labelled haven sqldf tinytex moments && \
  install2.r --error --skipmissing -l /var/lib/rock/R/library -r $ROCK_REPOS -d TRUE resourcer s3.resourcer odbc.resourcer dsBase dsTidyverse && \
  install2.r --error -r $ROCK_REPOS arrow && \
  # Binary packages do not check their system libraries at install time: load them
  Rscript -e ".libPaths(c('/var/lib/rock/R/library', .libPaths())); for (p in c('opalr', 'devtools', 'tidyverse', 'rmarkdown', 'labelled', 'haven', 'sqldf', 'moments', 'resourcer', 's3.resourcer', 'odbc.resourcer', 'dsBase', 'dsTidyverse', 'arrow', 'unixtools')) library(p, character.only = TRUE)" && \
  chown -R rock:rock /var/lib/rock && \
  chown -R rock:rock $ROCK_HOME

WORKDIR $ROCK_HOME
VOLUME $ROCK_HOME

EXPOSE 8085

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
