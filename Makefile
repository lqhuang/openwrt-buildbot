SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

export DEBIAN_FRONTEND := noninteractive
export N_PROC = $(shell nproc)

OPENWRT_VERSION ?= 23.05
OPENWRT_VERSION_PATCH ?= 23.05.2

OPENWRT_DOWNLOADS := https://downloads.openwrt.org
OPENWRT_RELEASES := ${OPENWRT_DOWNLOADS}/releases/${OPENWRT_VERSION_PATCH}/targets
OPENWRT_BUILD_TARGET := x86/64
OPENWRT_BUILD_TARGET_ARCH := x86_64
OPENWRT_IMAGEBUILDER = openwrt-imagebuilder-${OPENWRT_VERSION_PATCH}-$(subst _,-,${OPENWRT_BUILD_TARGET_ARCH}).Linux-${OPENWRT_BUILD_TARGET_ARCH}
# example: https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/openwrt-imagebuilder-23.05.2-x86-64.Linux-x86_64.tar.xz
URL_IMAGE_BUILD_ARTIFACT := ${OPENWRT_RELEASES}/${OPENWRT_BUILD_TARGET}/${OPENWRT_IMAGEBUILDER}.tar.xz

OPENWRT_REPO := https://github.com/openwrt/openwrt.git
BUILDROOT := openwrt

# directory to put customized files
CUSTOM = custom

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
	curl -L ${URL_IMAGE_BUILD_ARTIFACT} | tar -xJf - -C ./
	# cd ./${OPENWRT_IMAGEBUILDER}

setup-openwrt-src:
	git clone --depth 1 --branch openwrt-${OPENWRT_VERSION} ${OPENWRT_REPO} ./${BUILDROOT}
	# [[ $? -ne 0 ]] && pushd ${BUILDROOT} && git pull && popd

reformat-packages:
	@echo "Reformat packages..."
	python3 write-packages.py ./packages/*
	@echo "Done"

setup-provision:
	cat config >> ${CUSTOM}/.config
	python3 write-packages.py ./packages/* >> ${CUSTOM}/.config

	sed -i 's/src-git telephony/#src-git telephony/g' ${BUILDROOT}/feeds.conf.default
	cat ${CUSTOM}/feeds.conf.default >> ${BUILDROOT}/feeds.conf.default
	cat ${CUSTOM}/.config >> ${BUILDROOT}/.config

	rsync -ahP --delete ${CUSTOM}/files ${BUILDROOT}/

## Build stage

.PHONY: update-feeds configure pre-build build

update-feeds:
	pushd ${BUILDROOT}
	./scripts/feeds update -a
	./scripts/feeds install -a
	popd

configure: update-feeds
	@echo "Configuring ..."
	make -C ${BUILDROOT} menuconfig
	make -C ${BUILDROOT} defconfig
	# make  -C ${BUILDROOT} kernel_menuconfig # CONFIG_TARGET=subtarget

pre-build: configure
	make -C ${BUILDROOT} download
	make -C ${BUILDROOT} world -j${N_PROC}

build: pre-build
	make -C ${BUILDROOT} download
	make -C ${BUILDROOT} world -j${N_PROC}

	make -C ${BUILDROOT} -j${N_PROC}
	make -C ${BUILDROOT} checksum

clean:
	make -C ${BUILDROOT} clean

## Debug

.PHONY: rsync

# rsync files to myself debug server. Do not use this command.
rsync:
	rsync -azhP --delete \
		--exclude="**/.mypy_cache" --exclude=${BUILDROOT}  \
		./ build-server:~/app/openwrt-buildbot/
