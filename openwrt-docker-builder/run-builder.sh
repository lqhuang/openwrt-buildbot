#!/bin/bash

set -euo pipefail

TARGET="x86"
SUBTARGET="64"

NPROC=$(nproc)

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a
# ./scripts/feeds update -a && ./scripts/feeds install -a

cp -f .generated.config .config
make defconfig

ARTIFACTS_DIR="bin/targets/${TARGET}/${SUBTARGET}"
mkdir -p ${ARTIFACTS_DIR}
cp -f .config ${ARTIFACTS_DIR}/config.buildinfo

make download -j${NPROC}

#make clean
make -j${NPROC}

make json_overview_image_info
make checksum
