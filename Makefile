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
OPENWRT_VERSION ?= 24.10.0
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
GCC_VERSION         := 13.3.0
LLVM_VERSION        := 18.1.7

# url for artifacts
OPENWRT_URL_DOWNLOADS := https://downloads.openwrt.org
OPENWRT_URL_RELEASE := ${OPENWRT_URL_DOWNLOADS}/${OPENWRT_URL_VERSION}/targets

# example:
#   1. https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-toolchain-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
#   2. https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/openwrt-toolchain-23.05.2-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
FILE_PATTERN          := Linux-${OPENWRT_TARGET_NAME}.tar.xz
OPENWRT_SDK           := openwrt-sdk${ARTIFACT_PREFIX}-${OPENWRT_TARGET_VAR}_gcc-${GCC_VERSION}_musl.${FILE_PATTERN}
OPENWRT_LLVM_BPF      := llvm-bpf-${LLVM_VERSION}.${FILE_PATTERN}
OPENWRT_TOOLCHAIN     := openwrt-toolchain${ARTIFACT_PREFIX}-${OPENWRT_TARGET_VAR}_gcc-${GCC_VERSION}_musl.${FILE_PATTERN}
OPENWRT_IMAGEBUILDER  := openwrt-imagebuilder${ARTIFACT_PREFIX}-${OPENWRT_TARGET_VAR}.${FILE_PATTERN}
ARTIFACT_SRC          := https://github.com/openwrt/openwrt/archive/refs/tags/v${OPENWRT_VERSION}.tar.gz
ARTIFACT_SDK          := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_SDK}
ARTIFACT_LLVM_BPF     := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_LLVM_BPF}
ARTIFACT_TOOLCHAIN    := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_TOOLCHAIN}
ARTIFACT_IMAGEBUILDER := ${OPENWRT_URL_RELEASE}/${OPENWRT_TARGET}/${OPENWRT_IMAGEBUILDER}

# directory for build root
BUILDROOT  := openwrt
OUTPUTROOT := ${BUILDROOT}/bin/targets/${OPENWRT_TARGET}

# directory for docker builder
DOCKER_BUILDER := openwrt-docker-builder

# directory to put customized files
# Define which profile (under `profiles/` dir) to build
DIR_PROFILES := ./profiles
PROFILE      ?= x86_64-default
PROFILE_PATH ?= ${DIR_PROFILES}/${PROFILE}
CUSTOM_PACKAGES_CONFIG := 9999.custom.config

# directory to store final artifacts
BUILD_ARTIFACTS := artifacts
CACHE_DIR       := .cache
CACHE_DL        := ${CACHE_DIR}/dl
CACHE_CCACHE    := ${CACHE_DIR}/.ccache
CACHE_PREBUILT  := ${CACHE_DIR}/prebuilt

## Lazy default
default: setup-openwrt-src configure all

default-with-cached: pull-openwrt all

## For env debug
show-openwrt-envs:
	@echo OPENWRT_VERSION=${OPENWRT_VERSION}
	@echo OPENWRT_URL_RELEASE=${OPENWRT_URL_RELEASE}
	@echo OPENWRT_TARGET=${OPENWRT_TARGET}
	@echo ARTIFACT_SRC=${ARTIFACT_SRC}
	@echo ARTIFACT_SDK=${ARTIFACT_SDK}
	@echo ARTIFACT_LLVM_BPF=${ARTIFACT_LLVM_BPF}
	@echo ARTIFACT_TOOLCHAIN=${ARTIFACT_TOOLCHAIN}
	@echo ARTIFACT_IMAGEBUILDER=${ARTIFACT_IMAGEBUILDER}
	@echo PROFILE_PATH=${PROFILE_PATH}

show-nproc:
	echo ${NPROC}

## Setup stage
bootstrap:
	sudo -E apt update -y -qq
	sudo -E apt full-upgrade -y -qq
	# python3-distutils is deprecated after Ubuntu 24.04
	sudo -E apt install -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		wget curl xz-utils bzip2 unzip less rsync git file gawk \
		build-essential make mold python3 \
		libncurses-dev
	sudo -E apt autoremove -y -qq --purge
	sudo -E apt clean -qq

download-src:
	mkdir -p ${BUILDROOT}
	rm -rf ./${BUILDROOT}/*
	curl -L ${ARTIFACT_SRC} | tar --strip-component=1 -C ${BUILDROOT} -xzf -

download-image-builder:
	curl -L ${ARTIFACT_IMAGEBUILDER} | tar --strip-component=1 -C ./openwrt-imagebuilder -xJf -

download-sdk:
	# rm -rf ${CACHE_PREBUILT}/${OPENWRT_SDK}
	curl --output-dir ${CACHE_PREBUILT} -OL ${ARTIFACT_SDK}

download-toolchain:
	# rm -rf ${CACHE_PREBUILT}/${OPENWRT_TOOLCHAIN}
	curl --output-dir ${CACHE_PREBUILT} -OL ${ARTIFACT_TOOLCHAIN}

download-llvm-bpf:
	# rm -rf ${CACHE_PREBUILT}/${OPENWRT_LLVM_BPF}
	curl --output-dir ${CACHE_PREBUILT} -OL ${ARTIFACT_LLVM_BPF}

install-prebuilt-toolchain:
	mkdir -p ${BUILDROOT}/staging_dir
	tar --strip-component=1 -C ${BUILDROOT}/staging_dir -xJf ${CACHE_PREBUILT}/${OPENWRT_TOOLCHAIN}

install-prebuilt-llvm-bpf:
	mkdir -p ${BUILDROOT}/staging_dir
	tar -C ${BUILDROOT}/staging_dir -xJf ${CACHE_PREBUILT}/${OPENWRT_LLVM_BPF}

SDK_DIRNAME = $(basename $(basename ${OPENWRT_SDK}))
install-prebuilt-sdk:
	rm -rf ${BUILDROOT}/staging_dir ${BUILDROOT}/build_dir
	tar --strip-components=1 -C ${BUILDROOT} -xJf ${CACHE_PREBUILT}/${OPENWRT_SDK} ${SDK_DIRNAME}/staging_dir ${SDK_DIRNAME}/build_dir
	#rsync -aP -qi --delete ./openwrt-sdk/staging_dir ${BUILDROOT}/
	#rsync -aP -qi --delete ./openwrt-sdk/build_dir ${BUILDROOT}/

setup-openwrt-branch:
	git clone --depth 1 --single-branch --branch openwrt-${OPENWRT_VERSION} ${OPENWRT_REPO} ./${BUILDROOT}

setup-openwrt-tag:
	git clone --depth 1 --single-branch --branch v${OPENWRT_VERSION} ${OPENWRT_REPO} ./${BUILDROOT}

setup-openwrt-src:
	git clone --depth 1 --single-branch ${OPENWRT_REPO} ./${BUILDROOT}

pull-openwrt:
	pushd ${BUILDROOT}; git pull; popd

setup-cache:
	# ln -s ${CACHE_DL} ${BUILDROOT}/dl
	# ln -s ${CACHE_CCACHE} ${BUILDROOT}/.ccache
	rsync -ah ${CACHE_DL}/ ${BUILDROOT}/dl/
	# rsync -ah ${CACHE_CCACHE}/ ${BUILDROOT}/.ccache/

backup-cache:
	rsync -ah ${BUILDROOT}/dl/ ${CACHE_DL}/
	# rsync -ah ${BUILDROOT}/.ccache/ ${CACHE_CCACHE}/

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
	# pushd ${BUILDROOT}; git restore feeds.conf.default; popd
	sed -i 's/src-git telephony/#src-git telephony/g' ${BUILDROOT}/feeds.conf.default
	cat ${PROFILE_PATH}/feeds.conf.default >> ${BUILDROOT}/feeds.conf.default
	rsync -aP -q -kL --delete ${PROFILE_PATH}/files ${BUILDROOT}/

##############################
####### Build stage ##########
##############################

.PHONY: update-feeds install-feeds feeds defconfig configure reconfigure download build full-clean refresh

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

configure: provision feeds feeds defconfig
reconfigure: provision defconfig

refresh:
	mkdir -p ${BUILDROOT}/staging_dir/host/stamp
	mkdir -p ${BUILDROOT}/build_dir/host
	pushd ${BUILDROOT}; ./scripts/ext-tools.sh --refresh; popd

download:
	make -C ${BUILDROOT} download -j${NPROC}

world:
	make -C ${BUILDROOT} world -j${NPROC}

build: #refresh
	make -C ${BUILDROOT} -j${NPROC}
	make -C ${BUILDROOT} checksum

build-debug: #refresh
	make -C ${BUILDROOT} -j1 V=sc

VERSION = $(shell date +%Y%m%d)-$(shell cat ${OUTPUTROOT}/version.buildinfo)
collect:
	rsync -aP -qi --exclude packages ${OUTPUTROOT}/ ${BUILD_ARTIFACTS}/${VERSION}/
	cp -f ${BUILDROOT}/.config ${BUILD_ARTIFACTS}/${VERSION}/config-full.buildinfo

# run build
all: clean build collect

clean:
	rm -rf ${BUILDROOT}/bin
	make -C ${BUILDROOT} clean

full-clean:
	make backup-cache
	make -C ${BUILDROOT} config-clean
	make -C ${BUILDROOT} distclean
	pushd ${BUILDROOT}; git reset --hard; popd
	make setup-cache

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
