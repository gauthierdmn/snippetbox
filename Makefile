project_name := snippetbox
project_version := 0.0.1  # $(shell git describe --tags --always)

image_url := gauthierdmn/$(project_name)

working_directory := /app

dev-image: ## Build development image
	docker build \
		--target=dev \
		--tag=$(image_url)-dev \
		.
.PHONY: dev-image

image: ## Build production image
	docker build \
		--target=prod \
		--tag=$(image_url):$(project_version) \
		--tag=$(image_url) \
		.
.PHONY: image

dev: dev-image ## Run development container
	docker run \
		--name=$(project_name)-dev \
		-it \
		--rm \
		--volume="$(CURDIR):$(working_directory)" \
		$(image_url)-dev \
		/bin/bash

start: image ## Start application
	docker compose build && docker compose up
.PHONY: start

stop: ## Stop application
	docker compose down
.PHONY: stop

help: ## Show help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT = 1
COMPOSE_DOCKER_CLI_BUILD = 1

.DEFAULT_GOAL := help
