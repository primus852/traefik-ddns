MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

DOCKER_COMPOSE_DEV := docker compose -f compose.yml
DOCKER_COMPOSE_PROD := docker compose -f compose.yml -f compose.override.prod.yml

DOCKER_COMPOSE := $(DOCKER_COMPOSE_DEV)

ifeq ($(ENV),prod)
	DOCKER_COMPOSE := $(DOCKER_COMPOSE_PROD)
endif

start-ddns:
	  $(DOCKER_COMPOSE) up ddns -d --force-recreate
.PHONY: start-ddns

start-ofelia:
	  $(DOCKER_COMPOSE) up ofelia -d --force-recreate
.PHONY: start-ofelia

start-prometheus:
	  $(DOCKER_COMPOSE) up prometheus -d --force-recreate
	@PROMETHEUS_DOMAIN=$$(grep -E '^PROMETHEUS_DOMAIN=' .env | cut -d '=' -f 2); \
  		echo "Starting Prometheus under https://$$PROMETHEUS_DOMAIN/";
.PHONY: start-prometheus

start-grafana:
	  $(DOCKER_COMPOSE) up grafana -d --force-recreate
	@GRAFANA_DOMAIN=$$(grep -E '^GRAFANA_DOMAIN=' .env | cut -d '=' -f 2); \
  		echo "Starting Grafana under https://$$GRAFANA_DOMAIN/";
.PHONY: start-grafana

start-all:
	make start-ddns && \
	make start-ofelia && \
	make start-traefik && \
	make start-prometheus && \
	make start-grafana && \
	make start-whoami
.PHONY: start-all

start-whoami:
	$(DOCKER_COMPOSE) up whoami -d --force-recreate
	@WHOAMI_DOMAIN=$$(grep -E '^WHOAMI_DOMAIN=' .env | cut -d '=' -f 2); \
  		echo "Starting whoami service under https://$$WHOAMI_DOMAIN/";
.PHONY: start-whoami

start-traefik:
	$(DOCKER_COMPOSE) up traefik -d --force-recreate
	@if [ "$$(grep -E '^DASHBOARD_ENABLED=' .env | cut -d '=' -f 2)" = "true" ]; then \
		DASHBOARD_DOMAIN=$$(grep -E '^DASHBOARD_DOMAIN=' .env | cut -d '=' -f 2); \
		echo "Starting Dashboard under https://$$DASHBOARD_DOMAIN/"; \
	else \
		echo "Started, Dashboard is not enabled."; \
	fi
.PHONY: start-traefik

start-dev:
	$(DOCKER_COMPOSE) up ddns traefik -d --force-recreate
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