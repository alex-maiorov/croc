#!/bin/sh
# Copyright (c) 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

RUNDIR=${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}
mkdir -p "$RUNDIR"

# Pull the image using podman.
podman pull hpretl/iic-osic-tools:2025.12

# Run the container using podman run.
# We use --userns=keep-id to ensure that the host user's UID/GID is preserved inside the container,
# which ensures that mounted volumes are owned by the user rather than root.
# We use --security-opt label=disable to allow access to the host repository 
# without changing its SELinux labels (complying with the "no chmod/chown" constraint).
# We use :Z for the RUNDIR mount as it's a temporary directory created for this workflow.
# We do NOT use :z for the repository or X11 socket to avoid attempting to relabel host-owned files.
podman run -it --rm \
  --userns=keep-id \
  --security-opt label=disable \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -e PS1="\[\033[01;32m\]osic:\[\033[00m\]\[\033[01;34m\]\w\[\033[00m\] $" \
  -e DISPLAY=$DISPLAY \
  -e XDG_RUNTIME_DIR=$RUNDIR \
  -v "$(pwd):/fosic/designs/croc" \
  -v "$RUNDIR:$RUNDIR:Z" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  hpretl/iic-osic-tools:2025.12 --skip bash
