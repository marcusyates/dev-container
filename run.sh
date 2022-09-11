#!/usr/bin/bash
set -euo pipefail

docker run \
    --interactive --tty \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume ~/.ssh:/home/developer/.ssh \
    --env DISPLAY=${DISPLAY} \
    --name myintellij \
    --net host \
    --privileged \
    myintellij 

