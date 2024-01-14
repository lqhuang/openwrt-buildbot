## Config Make
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

## Global envs
export DEBIAN_FRONTEND := noninteractive
nproc = $(shell nproc)
ifeq ($(shell expr ${nproc} == 1),1)
	export NPROC = $(shell expr ${nproc} + 1)
else ifeq ($(shell expr ${nproc} \<= 4),1)
	# with less cores
	export NPROC = $(shell expr ${nproc} + 2)
else
	# with powerful machine
	export NPROC = $(shell expr ${nproc} + 4)
endif

## Envs for OpenWrt
OPENWRT_VERSION ?= 23.05
OPENWRT_VERSION_PATCH ?= 23.05.2
OPENWRT_DOWNLOADS := https://downloads.openwrt.org
OPENWRT_RELEASES := ${OPENWRT_DOWNLOADS}/releases/${OPENWRT_VERSION_PATCH}/targets
OPENWRT_BUILD_TARGET := x86/64
OPENWRT_BUILD_TARGET_ARCH := x86_64
OPENWRT_IMAGEBUILDER = openwrt-imagebuilder-${OPENWRT_VERSION_PATCH}-$(subst _,-,${OPENWRT_BUILD_TARGET_ARCH}).Linux-${OPENWRT_BUILD_TARGET_ARCH}
# example: https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/openwrt-imagebuilder-23.05.2-x86-64.Linux-x86_64.tar.xz
OPENWRT_IMAGE_BUILD_ARTIFACT := ${OPENWRT_RELEASES}/${OPENWRT_BUILD_TARGET}/${OPENWRT_IMAGEBUILDER}.tar.xz
OPENWRT_REPO := https://github.com/openwrt/openwrt.git

# directory for build root
BUILDROOT := openwrt
# directory for docker builder
DOCKER_BUILDER := openwrt-docker-builder
# directory to put customized files
CUSTOM := custom
CUSTOM_PACKAGES_CONFIG := 9999.custom.config
# directory to store final artifacts
ARTIFACTS := artifacts


## For env debug

show-nproc:
	echo ${NPROC}

show-cflags:
	echo ${CFLAGS}

## Setup stage
.PHONY: README.md

pre-setup:
	[ $(docker images -q) -ne '' ] && docker rmi `docker images -q`
	sudo -E rm -rf /usr/share/dotnet /etc/mysql /etc/php /etc/apt/sources.list.d /usr/local/lib/android
	sudo -E apt-mark hold grub-efi-amd64-signed
	sudo -E apt update -qq
	# sudo -E apt purge -y -qq azure-cli* docker* ghc* zulu* llvm* firefox google* dotnet* powershell* openjdk* mysql* php* mongodb* dotnet* snap*
	sudo -E apt full-upgrade -y -qq
	sudo -E apt install -y --no-install-recommends --no-install-suggests \
		build-essential clang g++ gcc-multilib g++-multilib \
		libncurses-dev libssl-dev zlib1g-dev \
		flex bison gawk git gettext xsltproc rsync curl wget unzip python3
	sudo -E systemctl daemon-reload
	sudo -E apt autoremove -y -qq --purge
	sudo -E apt clean -qq

setup-image-builder:
	curl -L ${OPENWRT_IMAGE_BUILD_ARTIFACT} | tar -xJf - -C ./

setup-openwrt-branch:
	git clone --depth 1 --single-branch --branch openwrt-${OPENWRT_VERSION} ${OPENWRT_REPO} ./${BUILDROOT}

setup-openwrt-tag:
	git clone --depth 1 --single-branch --branch v${OPENWRT_VERSION_PATCH} ${OPENWRT_REPO} ./${BUILDROOT}

setup-openwrt-src:
	git clone --depth 1 --single-branch ${OPENWRT_REPO} ./${BUILDROOT}

pull-buildroot:
	pushd ${BUILDROOT}; git pull; popd

reformat-packages:
	@echo "Reformat packages..."
	rm -f ${CUSTOM}/config/${CUSTOM_PACKAGES_CONFIG}
	python3 write-packages.py ${CUSTOM}/packages/* > ${CUSTOM}/config/${CUSTOM_PACKAGES_CONFIG}
	@echo "Done"

bump-config: reformat-packages
	rm -f ${CUSTOM}/.config ${CUSTOM}/.config.old
	rm -f ${BUILDROOT}/.config ${BUILDROOT}/.config.old
	cat ${CUSTOM}/config/*.config > ${BUILDROOT}/.config

bump-config-docker: reformat-packages
	rm -f ${CUSTOM}/.config ${CUSTOM}/.config.old
	cat ${CUSTOM}/config/*.config > ${DOCKER_BUILDER}/.generated.config

provision: bump-config
	pushd ${BUILDROOT}; git restore feeds.conf.default; popd
	sed -i 's/src-git telephony/#src-git telephony/g' ${BUILDROOT}/feeds.conf.default
	cat ${CUSTOM}/feeds.conf.default >> ${BUILDROOT}/feeds.conf.default
	cp -rf ${CUSTOM}/files ${BUILDROOT}/

## Build stage

.PHONY: update-feeds install-feeds feeds configure prepare pre-build build full-clean

update-feeds:
	pushd ${BUILDROOT}
	./scripts/feeds update -a
	popd

install-feeds:
	pushd ${BUILDROOT}
	./scripts/feeds install -a
	popd

feeds: update-feeds update-feeds

configure:
	@echo "Configuring ..."
	make -C ${BUILDROOT} defconfig
	# make  -C ${BUILDROOT} kernel_menuconfig # CONFIG_TARGET=subtarget
	cp -f ${BUILDROOT}/.config ${ARTIFACTS}/config.buildinfo

prepare: provision feeds configure

pre-build:
	make -C ${BUILDROOT} download -j${NPROC}
	# make -C ${BUILDROOT} clean world -j${NPROC}

build: pre-build
	make -C ${BUILDROOT} -j${NPROC}
	make -C ${BUILDROOT} checksum

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
		 build-server:~/app/openwrt-buildbot/${BUILDROOT}/.config ./${ARTIFACTS}/
