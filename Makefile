.PHONY: format format-check syntax-check lint test

format:
	@echo "Formatting shell scripts in script/..."
	@shfmt -w -i 2 -ci -bn script/

format-check:
	@echo "Checking shell script formatting..."
	@shfmt -d -i 2 -ci -bn script/

syntax-check:
	@echo "Checking bash syntax..."
	@for file in script/*; do \
		if [ -f "$$file" ] && [ -x "$$file" ]; then \
			echo "  Checking $$file"; \
			bash -n "$$file" || exit 1; \
		fi \
	done
	@echo "All scripts have valid bash syntax!"

lint:
	@echo "Linting shell scripts..."
	@for file in script/*; do \
		if [ -f "$$file" ] && [ -x "$$file" ] && [ "$$(basename $$file)" != "lib.sh" ]; then \
			echo "  Checking $$file"; \
			shellcheck -x "$$file" || exit 1; \
		fi \
	done
	@echo "All scripts passed shellcheck!"

test: syntax-check lint format-check
