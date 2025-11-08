.PHONY: format format-check syntax-check lint test help

format: ## Format all shell scripts with shfmt
	@echo "Formatting shell scripts in script/..."
	@shfmt -w -i 2 -ci -bn script/

format-check: ## Check if shell scripts are formatted (exits 1 if changes needed)
	@echo "Checking shell script formatting..."
	@shfmt -d -i 2 -ci -bn script/

syntax-check: ## Check bash syntax in all executable scripts
	@echo "Checking bash syntax..."
	@for file in script/*; do \
		if [ -f "$$file" ] && [ -x "$$file" ]; then \
			echo "  Checking $$file"; \
			bash -n "$$file" || exit 1; \
		fi \
	done
	@echo "All scripts have valid bash syntax!"

lint: ## Lint shell scripts with shellcheck
	@echo "Linting shell scripts..."
	@for file in script/*; do \
		if [ -f "$$file" ] && [ -x "$$file" ] && [ "$$(basename $$file)" != "lib.sh" ]; then \
			echo "  Checking $$file"; \
			shellcheck -x "$$file" || exit 1; \
		fi \
	done
	@echo "All scripts passed shellcheck!"

test: syntax-check lint format-check ## Run all checks (syntax + lint + format)

.DEFAULT_GOAL := help
