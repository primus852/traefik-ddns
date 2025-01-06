MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

start-ddns:
	  docker compose -f compose.yml up ddns -d --force-recreate
.PHONY: start-ddns

start-whoami:
	docker compose -f compose.yml up whoami -d --force-recreate
	@WHOAMI_DOMAIN=$$(grep -E '^WHOAMI_DOMAIN=' .env | cut -d '=' -f 2); \
  		echo "Starting whoami service under https://$$WHOAMI_DOMAIN/";
.PHONY: start-whoami

start-traefik:
	docker compose -f compose.yml up traefik -d --force-recreate
	@if [ "$$(grep -E '^DASHBOARD_ENABLED=' .env | cut -d '=' -f 2)" = "true" ]; then \
		DASHBOARD_DOMAIN=$$(grep -E '^DASHBOARD_DOMAIN=' .env | cut -d '=' -f 2); \
		echo "Starting Dashboard under https://$$DASHBOARD_DOMAIN/"; \
	else \
		echo "Started, Dashboard is not enabled."; \
	fi
.PHONY: start-traefik

start-all:
	docker compose -f compose.yml traefik ofelia whoami up -d --force-recreate
	@if [ "$$(grep -E '^DASHBOARD_ENABLED=' .env | cut -d '=' -f 2)" = "true" ]; then \
		DASHBOARD_DOMAIN=$$(grep -E '^DASHBOARD_DOMAIN=' .env | cut -d '=' -f 2); \
		echo "Starting Dashboard under https://$$DASHBOARD_DOMAIN/"; \
	else \
		echo "Started, Dashboard is not enabled."; \
	fi
.PHONY: start-all

start-dev:
	docker compose -f compose.yml up ddns traefik -d --force-recreate
	@if [ "$$(grep -E '^DASHBOARD_ENABLED=' .env | cut -d '=' -f 2)" = "true" ]; then \
		DASHBOARD_DOMAIN=$$(grep -E '^DASHBOARD_DOMAIN=' .env | cut -d '=' -f 2); \
		echo "Starting Dashboard under https://$$DASHBOARD_DOMAIN/"; \
	else \
		echo "Started, Dashboard is not enabled."; \
	fi
.PHONY: start-dev

stop:
	  docker compose stop
.PHONY: stop

down:
	  docker compose down
.PHONY: down