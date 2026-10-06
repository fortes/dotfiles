.PHONY: format format-check lint test

format:
	@echo "Formatting shell scripts in script/..."
	@shfmt -w -i 2 -ci -bn script/

format-check:
	@echo "Checking shell script formatting..."
	@shfmt -d -i 2 -ci -bn script/

# Stowed helpers and startup files get error-level checks only
lint:
	@echo "Linting shell scripts..."
	@shellcheck -x $$(grep -lE '^#!.*(bash|/sh)' script/*)
	@shellcheck -x --severity=error --shell=bash \
		stowed-files/bash/.profile stowed-files/bash/.bashrc \
		stowed-files/bash/.bash_profile stowed-files/bash/.aliases \
		$$(grep -rlE '^#!.*(bash|/sh)' stowed-files)

test: lint format-check
