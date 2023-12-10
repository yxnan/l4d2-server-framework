#!/bin/bash

L4D2_ROOT="$(dirname "$0")"/..

docker run -d --rm \
    --user $UID \
    -e USER=$USER -e HOME=/tmp/home \
    -v "$L4D2_ROOT/game":/L4D2 \
    steamcmd/steamcmd:ubuntu-22 \
        +force_install_dir /L4D2 \
        +login anonymous \
        +app_update 222860 \
        +quit

