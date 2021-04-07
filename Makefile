.PHONY: help clean test
.DEFAULT_GOAL := help

DOCKER_REPO="grafana/celery-exporter"
DOCKER_VERSION="latest"

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

all: clean test docker_build ## Clean and Build

clean: ## Clean folders
	rm -rf dist/ *.egg-info

test: ## Run tests and coverage
	coverage run -m pytest test/ \
  && coverage report

docker_build: ## Build Docker file
	export DOCKER_REPO
	export DOCKER_VERSION

	docker build \
		--build-arg DOCKER_REPO=${DOCKER_REPO} \
		--build-arg VERSION=${DOCKER_VERSION} \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		-f ./Dockerfile \
		-t ${DOCKER_REPO}:${DOCKER_VERSION} \
		.

help: ## Print this help
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

