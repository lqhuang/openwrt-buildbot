#!/bin/bash

set -euo pipefail

NPROC=$(nproc)

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a

make defconfig

cp -f .config artifacts/config.buildinfo

make download -j${NPROC}
# make clean world -j${NPROC}

make -j${NPROC}

make checksum
