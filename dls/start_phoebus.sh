#!/bin/bash

# A launcher for the phoebus container that allows X11 forwarding, modified from:
# https://github.com/epics-containers/ec-phoebus/blob/main/phoebus.sh

thisdir=$(realpath "$(dirname "${0}")")

# assume podman for now - change this to docker if needed
docker=podman
args="--security-opt=label=type:container_runtime_t"
image_tag=latest
settings=/settings/settings.ini
server=4918

XSOCK=/tmp/.X11-unix # X11 socket (but we mount the whole of tmp)
XAUTH=/tmp/.container.xauth.$USER
touch "$XAUTH"
xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
chmod 777 "$XAUTH"

x11="
-e DISPLAY
-v $XAUTH:$XAUTH
-e XAUTHORITY=$XAUTH
--net host
"

args=${args}"
-it
--pull newer
"

export MYHOME=/home/${USER}
# mount in your own home dir in same folder for access to external files
mounts="
-v=/tmp:/tmp
-v=${MYHOME}/.ssh:/root/.ssh
-v=${MYHOME}:${MYHOME}
-v=${thisdir}:/workspace
"

# if there is a settings.ini next to this script mount it over the default one
if [[ -f ${thisdir}/settings.ini ]]; then
    mounts+="-v=${thisdir}/settings.ini:{settings}"
fi

set -x
${docker} run ${mounts} ${args} ${x11} \
  ghcr.io/diamondlightsource/phoebus:"${image_tag}" \
  -settings ${settings} -server ${server} -add-modules=ALL-SYSTEM "${@}"
