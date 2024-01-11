export UID=$(shell id -u)
export GID=$(shell id -g)

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

exec:
	docker compose exec builder bash

cp-config-in:
	docker compose cp .generated.config builder:/builder/.config

cp-script-in:
	docker compose cp run-builder.sh builder:/builder/run-builder.sh

cp-all: cp-config-in cp-script-in

run-build:
	docker compose exec builder /builder/run-builder.sh

cp-config-out:
	docker compose cp builder:/builder/.config ../artifacts/config.buildinfo

cp-dl-out:
	docker compose cp builder:/builder/dl ./.cache/
