.PHONY: format format-check lint test

SHFMT = shfmt --indent 2 --case-indent --binary-next-line

# shfmt only finds files with a shebang or .sh/.bash extension
STARTUP_FILES = stowed-files/bash/.profile stowed-files/bash/.bashrc \
	stowed-files/bash/.bash_profile stowed-files/bash/.aliases

format:
	@echo "Formatting shell scripts..."
	@$(SHFMT) --write script/ stowed-files/
	@$(SHFMT) --write --language-dialect bash $(STARTUP_FILES)

format-check:
	@echo "Checking shell script formatting..."
	@$(SHFMT) --diff script/ stowed-files/
	@$(SHFMT) --diff --language-dialect bash $(STARTUP_FILES)

# Stowed helpers and startup files get error-level checks only
lint:
	@echo "Linting shell scripts..."
	@shellcheck --external-sources $$(grep -lE '^#!.*(bash|/sh)' script/*)
	@shellcheck --external-sources --severity=error --shell=bash $(STARTUP_FILES) \
		$$(grep -rlE '^#!.*(bash|/sh)' stowed-files)
	@shellcheck --severity=error --shell=sh stowed-files/ssh/.ssh/rc

test: lint format-check
