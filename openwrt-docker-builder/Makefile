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

cp-config:
	docker compose cp builder:/builder/.config ../artifacts/config.buildinfo
