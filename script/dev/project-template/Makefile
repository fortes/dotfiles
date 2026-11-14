SHELL := bash

.DEFAULT_GOAL := help

.PHONY: help setup doctor check

help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "Available targets:\n"} \
/^[[:alnum:]_.-]+:.*##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

setup: ## Install pinned tools and dependencies (safe to rerun)
	./script/setup

doctor: ## Check this machine can work on the project, and how to fix it if not
	./script/doctor

# Add lint and test targets as prerequisites
check: doctor ## Run all checks
