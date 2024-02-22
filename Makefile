## Config Make
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

## Global envs
export DEBIAN_FRONTEND := noninteractive
# nproc = $(shell nproc)
# ifeq ($(shell expr ${nproc} == 1),1)
# 	export NPROC = $(shell expr ${nproc} + 1)
# else ifeq ($(shell expr ${nproc} \<= 4),1)
# 	# with less cores
# 	export NPROC = $(shell expr ${nproc} + 2)
# else
# 	# with powerful machine
# 	export NPROC = $(shell expr ${nproc} + 4)
# endif
NPROC = $(shell nproc)

## Envs for OpenWrt
OPENWRT_REPO := https://github.com/openwrt/openwrt.git
OPENWRT_VERSION ?= snapshots
ifeq (${OPENWRT_VERSION}, snapshots)
	OPENWRT_URL_VERSION := snapshots
	ARTIFACT_PREFIX     :=
else
	OPENWRT_URL_VERSION := releases/${OPENWRT_VERSION}
	ARTIFACT_PREFIX     := -${OPENWRT_VERSION}
endif
OPENWRT_TARGET      := x86/64
OPENWRT_TARGET_NAME := x86_64
OPENWRT_TARGET_VAR  := $(subst /,-,${OPENWRT_TARGET})
GCC_VERSION         := 12.3.0
LLVM_VERSION        := 15.0.7

# url for artifacts
OPENWRT_URL_DOWNLOADS := https://downloads.openwrt.org
OPENWRT_URL_RELEASE := ${OPENWRT_URL_DOWNLOADS}/${OPENWRT_URL_VERSION}/targets

# example:
#   1. https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-toolchain-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
#   2. https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/openwrt-toolchain-23.05.2-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
FILE_PATTERN          := Linux-${OPENWRT_TARGET_ARCH}.tar.xz
OPENWRT_SDK           := openwrt-sdk${ARTIFACT_PREFIX}-${OPENWRT_TARGET_VAR}_gcc-${GCC_VERSION}_musl.${FILE_PATTERN}
OPENWRT_LLVM_BPF      := llvm-bpf-${LLVM_VERSION}.${FILE_PATTERN}
OPENWRT_TOOLCHAIN     := openwrt-toolchain${ARTIFACT_PREFIX}-${OPENWRT_TARGET_VAR}_gcc-${GCC_VERSION}_musl.${FILE_PATTERN}
OPENWRT_IMAGEBUILDER  := openwrt-imagebuilder${ARTIFACT_PREFIX}-${OPENWRT_TARGET_VAR}.${FILE_PATTERN}
ARTIFACT_SDK          := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_SDK}
ARTIFACT_LLVM_BPF     := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_LLVM_BPF}
ARTIFACT_TOOLCHAIN    := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_TOOLCHAIN}
ARTIFACT_IMAGEBUILDER := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_IMAGEBUILDER}

# directory for build root
BUILDROOT := openwrt
# directory for docker builder
DOCKER_BUILDER := openwrt-docker-builder

# directory to put customized files
# Define which profile (under `profiles/` dir) to build
DIR_PROFILES := ./profiles
PROFILE      := x86_64-mwan
PROFILE_PATH = ${DIR_PROFILES}/${PROFILE}
CUSTOM_PACKAGES_CONFIG := 9999.custom.config

# directory to store final artifacts
BUILD_ARTIFACTS := artifacts
CACHE_DIR := .cache
CACHE_DL  := ${CACHE_DIR}/dl
CACHE_CCACHE := ${CACHE_DIR}/.ccache
CACHE_PREBUILT := ${CACHE_DIR}/prebuilt

## For env debug
show-openwrt-envs:
	echo ${OPENWRT_VERSION}
	echo ${OPENWRT_URL_RELEASE}
	echo ${OPENWRT_TARGET}
	echo ${ARTIFACT_SDK}
	echo ${ARTIFACT_LLVM_BPF}
	echo ${ARTIFACT_TOOLCHAIN}
	echo ${ARTIFACT_IMAGEBUILDER}
	echo ${PROFILE_PATH}

show-nproc:
	echo ${NPROC}

## Setup stage
install-prerequisites:
	sudo -E apt update -y -qq
	sudo -E apt full-upgrade -y -qq
	sudo -E apt install -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		wget curl xz-utils bzip2 unzip less rsync git file gawk \
		build-essential make mold python3 python3-distutils \
		libncurses-dev
	sudo -E apt autoremove -y -qq --purge
	sudo -E apt clean -qq

setup-image-builder:
	mkdir -p ./openwrt-imagebuilder
	rm -rf ./openwrt-imagebuilder/*
	curl -L ${ARTIFACT_IMAGEBUILDER} | tar --strip-component=1 -C ./openwrt-imagebuilder -xJf -

setup-sdk:
	mkdir -p ./openwrt-sdk
	rm -rf ./openwrt-sdk/*
	curl -L ${ARTIFACT_SDK} | tar --strip-component=1 -C ./openwrt-sdk -xJf -

setup-toolchain:
	# rm -rf ${CACHE_PREBUILT}/${OPENWRT_TOOLCHAIN}
	curl --output-dir ${CACHE_PREBUILT} -OL ${ARTIFACT_TOOLCHAIN}

setup-llvm-bpf:
	# rm -rf ${CACHE_PREBUILT}/${OPENWRT_LLVM_BPF}
	curl --output-dir ${CACHE_PREBUILT} -OL ${ARTIFACT_LLVM_BPF}

setup-openwrt-branch:
	git clone --depth 1 --single-branch --branch openwrt-${OPENWRT_VERSION} ${OPENWRT_REPO} ./${BUILDROOT}

setup-openwrt-tag:
	git clone --depth 1 --single-branch --branch v${OPENWRT_VERSION} ${OPENWRT_REPO} ./${BUILDROOT}

setup-openwrt-src:
	git clone --depth 1 --single-branch ${OPENWRT_REPO} ./${BUILDROOT}

pull-openwrt:
	pushd ${BUILDROOT}; git pull; popd

setup-cache:
	ln -s ${CACHE_DL} ${BUILDROOT}/dl
	ln -s ${CACHE_CCACHE} ${BUILDROOT}/.ccache

install-prebuilt-sdk: #setup-sdk
	mkdir -p ${BUILDROOT}/staging_dir
	rsync -avP ./openwrt-sdk/staging_dir/host ${BUILDROOT}/staging_dir/
	pushd ${BUILDROOT}; ./scripts/ext-tools.sh --refresh; popd

# install-prebuilt:
# 	pushd ${BUILDROOT}
# 	mkdir -p ./build_dir/host
# 	mkdir -p ./staging_dir/host/stamp
# 	./scripts/ext-tools.sh \
# 		--host-build-dir ./build_dir/host \
# 		--host-staging-dir-stamp ./staging_dir/host/stamp \
# 		--tools ../${CACHE_PREBUILT}/${OPENWRT_TOOLCHAIN}
# 	./scripts/ext-tools.sh \
# 		--host-build-dir ./build_dir/host \
# 		--host-staging-dir-stamp ./staging_dir/host/stamp \
# 		--tools ../${CACHE_PREBUILT}/${OPENWRT_LLVM_BPF}
# 	popd

#########

reformat-packages:
	@echo "Reformat packages..."
	rm -f ${PROFILE_PATH}/config/${CUSTOM_PACKAGES_CONFIG}
	python3 write-packages.py ${PROFILE_PATH}/packages/* > ${PROFILE_PATH}/config/${CUSTOM_PACKAGES_CONFIG}
	@echo "Done"

bump-config: reformat-packages
	rm -f ${PROFILE_PATH}/.config ${PROFILE_PATH}/.config.old
	rm -f ${BUILDROOT}/.config ${BUILDROOT}/.config.old
	cat ${PROFILE_PATH}/config/*.config > ${BUILDROOT}/.config

bump-config-docker: reformat-packages
	rm -f ${PROFILE_PATH}/.config ${PROFILE_PATH}/.config.old
	cat ${PROFILE_PATH}/config/*.config > ${DOCKER_BUILDER}/.generated.config

provision: bump-config
	pushd ${BUILDROOT}; git restore feeds.conf.default; popd
	sed -i 's/src-git telephony/#src-git telephony/g' ${BUILDROOT}/feeds.conf.default
	cat ${PROFILE_PATH}/feeds.conf.default >> ${BUILDROOT}/feeds.conf.default
	cp -rf ${PROFILE_PATH}/files ${BUILDROOT}/

## Build stage

.PHONY: update-feeds install-feeds feeds defconfig configure reconfigure download build full-clean

update-feeds:
	pushd ${BUILDROOT}
	./scripts/feeds update -a
	popd

install-feeds:
	pushd ${BUILDROOT}
	./scripts/feeds install -a
	popd

feeds: update-feeds install-feeds

defconfig:
	@echo "Check and generate .config file ..."
	make -C ${BUILDROOT} defconfig
	# make  -C ${BUILDROOT} kernel_menuconfig # CONFIG_TARGET=subtarget
	cp -f ${BUILDROOT}/.config ${BUILD_ARTIFACTS}/config.buildinfo

configure: provision feeds defconfig
reconfigure: provision defconfig

download:
	make -C ${BUILDROOT} download -j${NPROC}
	pushd ${BUILDROOT}; ./scripts/ext-tools.sh --refresh; popd
	#make -C ${BUILDROOT} clean -j${NPROC}
	#make -C ${BUILDROOT} world -j${NPROC}

build:
	make -C ${BUILDROOT} -j${NPROC}
	make -C ${BUILDROOT} checksum

build-debug:
	make -C ${BUILDROOT} -j1 V=sc

full-clean:
	make -C ${BUILDROOT} config-clean
	make -C ${BUILDROOT} distclean
	pushd ${BUILDROOT}; git reset --hard; popd

## Debug

.PHONY: rsync

# rsync files to myself debug server. Do not use this command.
rsync:
	rsync -azhP --delete \
		--exclude="**/.mypy_cache" --exclude=${BUILDROOT}  \
		./ build-server:~/app/openwrt-buildbot/

rsync-back:
	rsync -azhP --delete \
		 build-server:~/app/openwrt-buildbot/${BUILDROOT}/.config ./${BUILD_ARTIFACTS}/
