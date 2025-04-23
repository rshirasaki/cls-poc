restart:
	docker compose down
	docker compose up -d

stop:
	docker compose down

start:
	docker compose up -d

build:
	docker compose build
