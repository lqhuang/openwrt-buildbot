export UID=$(shell id -u)
export GID=$(shell id -g)

# defined at https://github.com/openwrt/docker/blob/main/Dockerfile#L45
WORKDIR := /builder
WORKDIR := /root/imagebuilder
USER	:= buildbot

# --------

default: pull down up setup-prebuilt run-build cp-out

# --------

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

pull:
	docker compose pull

# --------

exec:
	docker compose exec builder bash

exec-root:
	docker compose exec --user root builder bash

# --------

.PHONY: run-build
run-build:
	docker compose exec builder ${WORKDIR}/run-builder.sh

.PHONY: setup-prebuilt
setup-prebuilt:
	docker compose exec builder ${WORKDIR}/setup-prebuilt.sh

# --------

cp-config-in:
	docker compose cp .generated.config builder:${WORKDIR}/.config

cp-feeds-in:
	docker compose cp feeds.conf.default builder:${WORKDIR}/feeds.conf.default

cp-files-in:
	docker compose cp ../custom/files builder:${WORKDIR}/files

cp-scripts-in:
	docker compose cp run-builder.sh builder:${WORKDIR}/run-builder.sh
	docker compose cp setup-prebuilt.sh builder:${WORKDIR}/setup-prebuilt.sh

cp-all: cp-config-in cp-script-in

# --------

cp-config-out:
	docker compose cp builder:${WORKDIR}/.config ./config.buildinfo

cp-dl-out:
	docker compose cp builder:${WORKDIR}/dl ./.cache/

cp-ccache-out:
	docker compose cp builder:${WORKDIR}/.ccache ./.cache/

dump-cache: cp-dl-out cp-ccache-out

cp-out: cp-config-out dump-cache
