#
# Rock R Server Dockerfile
#
# https://github.com/obiba/docker-rock
#

FROM obiba/docker-gosu:latest AS gosu

FROM obiba/obiba-r:4.0

LABEL OBiBa <dev@obiba.org>

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV ROCK_VERSION master

FROM maven:3.6.0-slim AS building

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends devscripts debhelper build-essential fakeroot git wget

# Build Rock
WORKDIR /projects
RUN git clone https://github.com/obiba/rock.git

WORKDIR /projects/rock

RUN git checkout $ROCK_VERSION; \
    mvn clean install && \
    mvn -Prelease org.apache.maven.plugins:maven-antrun-plugin:run@make-deb

FROM obiba/obiba-r:4.0

ENV ROCK_MANAGER_NAME manager
ENV ROCK_MANAGER_PASSWORD password
ENV ROCK_USER_NAME user
ENV ROCK_USER_PASSWORD password
ENV ROCK_HOME /srv
ENV JAVA_OPTS -Xmx2G

WORKDIR /tmp
COPY --from=building /projects/rock/target/rock_*.deb .
RUN apt-get update && \
    apt-get install -y --no-install-recommends daemon psmisc && \
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

# AppArmor
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libapparmor-dev apparmor-utils 
#RUN Rscript -e "install.packages('RAppArmor', repos=c('https://cloud.r-project.org'), dependencies=TRUE, lib='/usr/local/lib/R/site-library')"
#RUN cp -Rf /usr/local/lib/R/site-library/RAppArmor/profiles/debian/* /etc/apparmor.d/

# Update R packages
#RUN Rscript -e "update.packages(ask = FALSE, repos = c('https://cloud.r-project.org'), instlib = '/usr/local/lib/R/site-library')"

VOLUME /srv

EXPOSE 8085

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
