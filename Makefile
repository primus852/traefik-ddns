MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

start-ddns:
	  docker compose -f compose.yml up ddns -d --force-recreate
.PHONY: start-ddns

start-traefik:
	  docker compose -f compose.yml up traefik -d --force-recreate
.PHONY: start-traefik

start:
	  docker compose -f compose.yml up -d --force-recreate
.PHONY: start

stop:
	  docker compose stop
.PHONY: stop

down:
	  docker compose down
.PHONY: down