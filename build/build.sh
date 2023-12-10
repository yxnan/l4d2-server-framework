#!/bin/bash

docker buildx build \
    -t yxnan/l4d2-runner \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    --build-arg UNAME=$USER \
    "$(dirname "$0")"

: <<'comment'
 additional args:
    --build-arg DEFAULT_PORT=27015 \
    --build-arg DEFAULT_MAP=c2m1_highway \
    --build-arg DEFAULT_LOG=on \
    --build-arg DEFAULT_CONFIG="server.cfg" \
    --build-arg DEFAULT_TICKRATE=30 \
comment
