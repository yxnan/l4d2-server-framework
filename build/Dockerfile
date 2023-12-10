FROM ubuntu:22.04 AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates locales steamcmd \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/games/steamcmd /usr/bin/steamcmd

RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

ARG UID=1000
ARG GID=1000
ARG UNAME=l4d2
ARG HOME=/home/$UNAME
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o $UNAME -d $HOME
USER $UNAME

RUN steamcmd +quit

RUN mkdir -p $HOME/.steam \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux32 $HOME/.steam/sdk32 \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux64 $HOME/.steam/sdk64 \
 && ln -s $HOME/.steam/sdk32/steamclient.so $HOME/.steam/sdk32/steamservice.so \
 && ln -s $HOME/.steam/sdk64/steamclient.so $HOME/.steam/sdk64/steamservice.so

# game
FROM base AS game

ARG DEFAULT_PORT=27015
ARG DEFAULT_MAP=c2m1_highway
ARG DEFAULT_LOG=on
ARG DEFAULT_CONFIG="server.cfg"
ARG DEFAULT_TICKRATE=30
ARG GAME_DIR="/L4D2"

ENV MAP=$DEFAULT_MAP \
    PORT=$DEFAULT_PORT \
    LOG=$DEFAULT_LOG \
    CONFIG=$DEFAULT_CONFIG \
    TICKRATE=$DEFAULT_TICKRATE

WORKDIR "$GAME_DIR"

CMD ["sh", "-c", "./srcds_run -port $PORT +map $MAP +log $LOG +servercfgfile $CONFIG -insecure -tickrate $TICKRATE" ]

