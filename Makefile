SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

export DEBIAN_FRONTEND := noninteractive
N_PROC = $(shell nproc)

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
OPENWRT_SRC := openwrt

BUILDROOT = ./buildroot

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
	git clone --depth 1 --branch openwrt-${OPENWRT_VERSION} ${OPENWRT_REPO} ./${OPENWRT_SRC}

setup-provision:
	# python3 collect-packages.py
	sed -i 's/src-git telephony/#src-git telephony/g' ${OPENWRT_SRC}/feeds.conf.default
	cat ${BUILDROOT}/feeds.conf.default >> ${OPENWRT_SRC}/feeds.conf.default
	rsync -ahP --delete ${BUILDROOT}/files ${OPENWRT_SRC}/

resort-packages:
	@echo "Resorting packages..."
	python3 sort-packages.py app.txt
	python3 sort-packages.py luci.txt
	@echo "Done"

## Build stage

.PHONY: update-feeds build

update-feeds:
	pushd ${OPENWRT_SRC}
	./scripts/feeds update -a
	./scripts/feeds install -a


build: update-feeds
	@echo "Building..."
	make -C ${OPENWRT_SRC} menuconfig

	make -C ${OPENWRT_SRC} defconfig
	make -C ${OPENWRT_SRC} download -j${N_PROC}
	make -C ${OPENWRT_SRC} clean -j${N_PROC}

	make -C ${OPENWRT_SRC} -j${N_PROC}

.PHONY: rsync
rsync:
	# rsync files to myself debug server. Do not use this command.
	rsync -azhP --delete \
		--exclude="**/.mypy_cache" --exclude="openwrt"  \
		./ build-server:~/app/openwrt-buildbot/
