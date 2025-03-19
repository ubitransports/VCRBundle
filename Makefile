DOCKER_COMPOSE = docker-compose
EXEC_PHP = $(DOCKER_COMPOSE) exec php

PHPTOOLS = docker run -v $$PWD:/app --rm -w /app europe-west1-docker.pkg.dev/ubitransport-tools/services/nginx-php8.3-dev-server
PHPSTAN = $(PHPTOOLS) phpstan

ifdef level
	PHPSTAN_LEVEL = --level $(level)
endif

ifdef baseline_file
	BASELINE_FILE = $(baseline_file)
endif

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

bash: ## Run bash in php container
	$(EXEC_PHP) bash

start: ## Start the containers
	$(DOCKER_COMPOSE) up -d --remove-orphans --force-recreate

stop: ## Stop the containers
	$(DOCKER_COMPOSE) stop

phpstan-analyse: ## Run phpstan analyse using phpstan.neon configuration file. Add level=PhpStanLevelHere to use a specific level between 0 and 9.
	$(PHPSTAN) analyse --configuration='./phpstan.neon.dist'

phpstan-generate-baseline: ## Run phpstan analyse and generate a baseline. Add baseline_file=PhpStanBaseLineFileNameHere to set the baseline file name (default: current-baseline.neon).
	$(PHPSTAN) analyse $(PHPSTAN_LEVEL) --generate-baseline $(BASELINE_FILE)

cs-fixer-check: ## check code style.
	$(PHPTOOLS) php-cs-fixer fix --config=/root/.composer/vendor/ubitransport/coding-standards/config/.php_cs_microservice.dist --verbose --dry-run --diff

cs-fixer-fix: ## fix code style.
	$(PHPTOOLS) php-cs-fixer fix --config=/root/.composer/vendor/ubitransport/coding-standards/config/.php_cs_microservice.dist --verbose --diff

ci: phpstan-analyse cs-fixer-check
