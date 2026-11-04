.PHONY: format format-check lint test

# shfmt only finds files with a shebang or .sh/.bash extension
STARTUP_FILES = stowed-files/bash/.profile stowed-files/bash/.bashrc \
	stowed-files/bash/.bash_profile stowed-files/bash/.aliases

format:
	@echo "Formatting shell scripts..."
	@shfmt -w -i 2 -ci -bn script/ stowed-files/
	@shfmt -w -i 2 -ci -bn -ln=bash $(STARTUP_FILES)

format-check:
	@echo "Checking shell script formatting..."
	@shfmt -d -i 2 -ci -bn script/ stowed-files/
	@shfmt -d -i 2 -ci -bn -ln=bash $(STARTUP_FILES)

# Stowed helpers and startup files get error-level checks only
lint:
	@echo "Linting shell scripts..."
	@shellcheck -x $$(grep -lE '^#!.*(bash|/sh)' script/*)
	@shellcheck -x --severity=error --shell=bash $(STARTUP_FILES) \
		$$(grep -rlE '^#!.*(bash|/sh)' stowed-files)
	@shellcheck --severity=error --shell=sh stowed-files/ssh/.ssh/rc

test: lint format-check
