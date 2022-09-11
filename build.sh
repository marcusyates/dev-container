#!/usr/bin/bash
set -euo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# use parallel builds
DOCKER_BUILDKIT=1 docker \
  build \
  --tag myintellij \
  --file ./Dockerfile \
  ${SCRIPT_DIR}

