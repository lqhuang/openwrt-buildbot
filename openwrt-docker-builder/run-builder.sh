#!/bin/bash

set -euo pipefail

NPROC=$(nproc)

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a

make defconfig

BIN_DIR="bin/targets/x86/64"
mkdir -p ${BIN_DIR}
cp -f .config ${BIN_DIR}/config.buildinfo

make download -j${NPROC}
make clean world -j${NPROC}

make -j${NPROC}
make checksum
