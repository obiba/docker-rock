#
# Rock R Server Dockerfile
#
# https://github.com/obiba/docker-rock
#

FROM obiba/docker-gosu:latest AS gosu

LABEL OBiBa <dev@obiba.org>

FROM obiba/obiba-r:4.1 AS server

ENV ROCK_VERSION 1.0.8
ENV ROCK_HOME /srv
ENV JAVA_OPTS -Xmx2G

WORKDIR /tmp

# Install Rock Server
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O rock.zip https://github.com/obiba/rock/releases/download/${ROCK_VERSION}/rock-${ROCK_VERSION}-dist.zip && \
  unzip -q rock.zip && \
  rm rock.zip && \
  mv rock-${ROCK_VERSION} rock && \
  adduser --system --home /var/lib/rock --no-create-home --disabled-password rock; \
  chmod +x /usr/share/rock/bin/rock

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

RUN chmod +x /usr/share/rock/bin/rock

COPY bin /opt/obiba/bin
COPY conf/application.yml /usr/share/rock/conf/application.yml
COPY conf/Rserv.conf /usr/share/rock/conf/Rserv.conf
COPY conf/Rprofile.R /usr/share/rock/conf/Rprofile.R

RUN chmod +x -R /opt/obiba/bin && \
  chown -R rock /opt/obiba && \
  mkdir -p /var/lib/rock/R/library && chown -R rock /var/lib/rock

RUN \
  # Additional system dependencies
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y procps libsasl2-dev libssh-dev libgit2-dev libmariadb-dev libmariadb-dev-compat libpq-dev libsodium-dev libgit2-dev libssh2-1-dev openssh-client && \
  # Update R packages
  #RUN Rscript -e "update.packages(ask = FALSE, repos = c('https://cloud.r-project.org'), instlib = '/usr/local/lib/R/site-library')" && \
  # Install required R packages
  Rscript -e "install.packages('Rserve', '/usr/local/lib/R/site-library', 'http://www.rforge.net/')" && \
  Rscript -e "install.packages(c('resourcer'), repos = c('https://cloud.r-project.org'), lib = c('/var/lib/rock/R/library'), dependencies = TRUE)" && \
  chown -R rock /var/lib/rock/R/library

WORKDIR $ROCK_HOME
VOLUME $ROCK_HOME

EXPOSE 8085

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
