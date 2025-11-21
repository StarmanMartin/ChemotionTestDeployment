# This dockerfile is used by docker-compose.dev.yml
# It builds a container with all the necessary gems to run chemotion ELN
# WARNING: Building this container initially takes a lot of time, due to gem compiling, so grab a coffee
# and write some documentation meanwhile ;)

FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

RUN set -xe  && apt-get update -yqqq --fix-missing && apt-get upgrade -y
RUN apt update && apt-get install -yqq --fix-missing bash ca-certificates wget apt-transport-https git gpg \
      build-essential sudo postgresql-common swig cmake \
      libnspr4 libnss3 libxss1 xdg-utils tzdata

RUN apt-get install -yqq --fix-missing  \
      libyaml-dev \
      libpq-dev \
      imagemagick libmagic-dev libmagickcore-dev libmagickwand-dev curl \
      gtk2-engines-pixbuf \
      libssl-dev libreadline-dev \
      unzip openssh-client

RUN apt-get install -yqq --fix-missing  \
      libsqlite3-dev libboost-all-dev p7zip-full \
      xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable \
      fonts-crosextra-caladea fonts-crosextra-carlito \
      fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-liberation2 fonts-liberation \
      fonts-linuxlibertine fonts-noto-core fonts-noto-extra fonts-noto-ui-core \
      fonts-opensymbol fonts-sil-gentium fonts-sil-gentium-basic inkscape \
      libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libxtst6 \
      xauth xvfb

RUN apt-get install -yqq ranger nano vim jq


RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
RUN apt-get update && apt-get install -yqq --fix-missing postgresql-client-16

RUN mkdir /shared
RUN mkdir /backup
RUN mkdir /restore
RUN mkdir /shell_scripts


RUN mkdir /chemotion

WORKDIR /chemotion

COPY ./etc_doc/db_backup.rake ./db_backup.rake
COPY ./etc_doc/db_restore.rake ./db_restore.rake

# Create node modules folder OUTSIDE of application directory

SHELL ["/bin/bash", "-c"]

ENV PIDFILE=/chemotion/pid_run
ENV RAILS_PIDFILE=/chemotion/pid
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Even if asdf and the related tools are only installed by running run-ruby-dev.sh, we set the PATH variables here, so when we enter the container via docker exec, we have the path set correctly
ENV ASDF_DIR=/root/.asdf
ENV PATH=/root/.asdf/shims:/root/.asdf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY ./etc_doc/*.sh ./
RUN chmod +x ./*.sh


CMD bash ./entrypoint.sh