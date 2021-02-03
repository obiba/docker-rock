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
ENV RSERVE_VERSION 1.8-7

ENV ROCK_MANAGER_NAME manager
ENV ROCK_MANAGER_PASSWORD password
ENV ROCK_USER_NAME user
ENV ROCK_USER_PASSWORD password
ENV ROCK_HOME /srv
ENV JAVA_OPTS -Xmx2G

# Make sure latest known Rserve is installed
RUN wget -q https://www.rforge.net/Rserve/snapshot/Rserve_${RSERVE_VERSION}.tar.gz && \
  tar -xf Rserve_${RSERVE_VERSION}.tar.gz && \
  R CMD INSTALL Rserve_${RSERVE_VERSION}.tar.gz

FROM maven:3.5.4-slim AS building

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends devscripts debhelper build-essential fakeroot git

# Build Rock
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O rock.zip https://github.com/obiba/rock/releases/download/${ROCK_VERSION}/rock-${ROCK_VERSION}-dist.zip && \
  unzip -q rock.zip && \
  rm rock.zip && \
  mv rock-${ROCK_VERSION} rock

WORKDIR /projects
RUN git clone https://github.com/obiba/rock.git

WORKDIR /projects/rock

RUN git checkout $ROCK_VERSION; \
    mvn clean install && \
    mvn -Prelease org.apache.maven.plugins:maven-antrun-plugin:run@make-deb

FROM openjdk:8-jdk-stretch AS server

WORKDIR /tmp
COPY --from=building /projects/rock/target/rock_*.deb .
RUN apt-get update && \
    apt-get install -y --no-install-recommends daemon psmisc && \
    DEBIAN_FRONTEND=noninteractive dpkg -i rock_*.deb && \
    rm rock_*.deb

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

RUN chmod +x /usr/share/rock/bin/rock

COPY bin /opt/obiba/bin
COPY conf/Rserv.conf /usr/share/rock/conf/Rserv.conf
COPY conf/Rprofile.R /usr/share/rock/conf/Rprofile.R
RUN mkdir -p $ROCK_HOME/conf && cp -r /usr/share/rock/conf/* $ROCK_HOME/conf
RUN adduser --system --home $ROCK_HOME --no-create-home --disabled-password rock

RUN chmod +x -R /opt/obiba/bin && chown -R rock:adm $ROCK_HOME
RUN chown -R rock:adm /opt/obiba

# Additional system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libsasl2-dev libssh-dev libgit2-dev libmariadbclient-dev libpq-dev libsodium-dev libgit2-dev libssh2-1-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev
RUN Rscript -e "update.packages(ask = FALSE, repos = c('https://cloud.r-project.org'), instlib = '/usr/local/lib/R/site-library')"
RUN Rscript -e "install.packages(c('gh', 'Cairo', 'multcomp', 'lme4', 'betareg', 'modeltools', 'mvtnorm', 'TH.data', 'nloptr', 'flexmix'), repos=c('https://cloud.r-project.org'), dependencies=TRUE, lib='/usr/local/lib/R/site-library')"
RUN Rscript -e "BiocManager::install(c('Biobase','GWASTools', 'limma', 'SummarizedExperiment', 'SNPRelate', 'GENESIS', 'MEAL', 'CopyNumber450kData'), ask = FALSE, dependencies=TRUE, lib='/usr/local/lib/R/site-library')"
RUN Rscript -e "remotes::install_github('perishky/meffil', repos=c('https://cloud.r-project.org'), lib='/usr/local/lib/R/site-library')"

VOLUME /srv

EXPOSE 6312

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
