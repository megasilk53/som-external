#!/bin/bash
# Run this on the host to create the workspace for Docker COPY
# All repos are public — no credentials required.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$SCRIPT_DIR/workspace"

if [ -d "$WORKSPACE/.repo" ]; then
    echo "Workspace already exists, running repo sync..."
    cd "$WORKSPACE"
    repo sync -j8
else
    echo "Creating workspace..."
    mkdir -p "$WORKSPACE"
    cd "$WORKSPACE"
    repo init \
        -u https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git \
        -b if91x-mfg \
        -m carbon_13.0.57.22_if91x_devel.xml \
        --depth=1
    repo sync -j8
fi

echo "Workspace ready at $WORKSPACE"
echo "Now run: docker build -t if91x-mfg-repo:1.0 $SCRIPT_DIR"
