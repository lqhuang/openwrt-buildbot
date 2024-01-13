#!/bin/bash

set -e

FILE_NAME="llvm-bpf-15.0.7.Linux-x86_64.tar.xz"
DOWNLOAD_URL="https://downloads.openwrt.org/snapshots/targets/x86/64/${FILE_NAME}"
DL_DIR="${PWD}/dl"

BUILD_HOST_DIR="${PWD}/build_dir/host"
STAGING_HOST_DIR="${PWD}/staging_dir/host"
STAGING_HOST_STAMP_DIR="${STAGING_HOST_DIR}/stamp"
EXT_TOOLS="${PWD}/scripts/ext-tools.sh"

mkdir -p "${DL_DIR}"

if [ ! -f "${DL_DIR}/${FILE_NAME}" ]; then
    echo "Downloading ${FILE_NAME}..."
    curl -o "${DL_DIR}/${FILE_NAME}" -L "${DOWNLOAD_URL}"
fi

mkdir -p "${BUILD_HOST_DIR}"
mkdir -p "${STAGING_HOST_STAMP_DIR}"

echo "Extracting ${FILE_NAME}..."
${EXT_TOOLS} --tools "${DL_DIR}/${FILE_NAME}"
${EXT_TOOLS} --refresh

echo "Successfully setup prebuilt LLVM toolchain!"
