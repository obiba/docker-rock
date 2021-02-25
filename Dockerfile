#
# Rock R Server Dockerfile
#
# https://github.com/obiba/docker-rock
#

FROM obiba/docker-gosu:latest AS gosu

LABEL OBiBa <dev@obiba.org>

FROM obiba/obiba-r:4.0 AS server

ENV ROCK_VERSION 0.9.0
ENV ROCK_MANAGER_NAME manager
ENV ROCK_MANAGER_PASSWORD password
ENV ROCK_USER_NAME user
ENV ROCK_USER_PASSWORD password
ENV ROCK_HOME /srv
ENV JAVA_OPTS -Xmx2G

WORKDIR /tmp
RUN wget -q https://github.com/obiba/rock/releases/download/${ROCK_VERSION}/rock_${ROCK_VERSION}_all.deb
RUN apt-get update && \
    apt-get install -y --no-install-recommends daemon psmisc procps && \
    DEBIAN_FRONTEND=noninteractive dpkg -i rock_*.deb && \
    rm rock_*.deb

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

RUN chmod +x /usr/share/rock/bin/rock

COPY bin /opt/obiba/bin
COPY conf/application.yml /usr/share/rock/conf/application.yml
COPY conf/Rserv.conf /usr/share/rock/conf/Rserv.conf
COPY conf/Rprofile.R /usr/share/rock/conf/Rprofile.R

RUN chmod +x -R /opt/obiba/bin
RUN chown -R rock:adm /opt/obiba

# Additional system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libsasl2-dev libssh-dev libgit2-dev libmariadbclient-dev libpq-dev libsodium-dev libgit2-dev libssh2-1-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev

# Update R packages
#RUN Rscript -e "update.packages(ask = FALSE, repos = c('https://cloud.r-project.org'), instlib = '/usr/local/lib/R/site-library')"

WORKDIR $ROCK_HOME
VOLUME $ROCK_HOME

EXPOSE 8085

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
