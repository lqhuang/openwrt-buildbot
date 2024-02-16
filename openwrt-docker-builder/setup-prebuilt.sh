#!/bin/bash

set -euo pipefail

PRE_INSTALL="wget curl ca-certificates xz-utils less git"
BUILD_PRE_INSTALL="build-essential clang  make"
MUSL_LIBC="argp-standalone musl-fts-dev musl-obstack-dev musl-libintl"
MOLD="libncurses-dev libssl-dev rsync gawk unzip bzip2 python3 python3-distutils file libpam-dev"
# "liblzma-dev libsnmp-dev"

FILE_PATTERN="Linux-x86_64.tar.xz"
BPF_TOOLCHAIN_DOWNLOAD_FILE="llvm-bpf-15.0.7.${FILE_PATTERN}"
IMAGEBUILDER_DOWNLOAD_FILE="openwrt-imagebuilder-x86-64.${FILE_PATTERN}"
SDK_DOWNLOAD_FILE="openwrt-sdk-x86-64_gcc-12.3.0_musl.${FILE_PATTERN}"
TOOLCHAIN_DOWNLOAD_FILE="openwrt-toolchain-x86-64_gcc-12.3.0_musl.${FILE_PATTERN}"

# FILE_HOST=mirrors.cloud.tencent.com/openwrt
FILE_HOST=mirror.nju.edu.cn/openwrt
VERSION_PATH="${VERSION_PATH:-snapshots}"
DOWNLOAD_PATH="${VERSION_PATH}/targets/${TARGET}"
TARGET="${TARGET:-x86/64}"

DL_DIR="${PWD}/dl"

curl "https://$FILE_HOST/$DOWNLOAD_PATH/sha256sums" -fs -o sha256sums
echo $(grep "$FILE_PATTERN" sha256sums | cut -d "*" -f 2) | FILES=$(< /dev/stdin)
for FILE in $FILES; do
    echo "Downloading $FILE..."
    curl -o "${DL_DIR}/${FILE}" -L "https://$FILE_HOST/$DOWNLOAD_PATH/$FILE"
done

WORKDIR="${PWD}/workdir"
mkdir -p "${WORKDIR}"
for FILE in $FILES; do
    echo "Extracting $FILE..."
    tar -xf "${DL_DIR}/${FILE}"  --strip=1 --no-same-owner -C ${WORKDIR}
done

##

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
