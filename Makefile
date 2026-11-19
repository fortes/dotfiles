.PHONY: format format-check lint ssh-check test

SHFMT = shfmt --indent 2 --case-indent --binary-next-line

# shfmt only finds files with a shebang or .sh/.bash extension; these are
# sourced, so they have neither
STARTUP_FILES = stowed-files/bash/.profile stowed-files/bash/.bashrc \
	stowed-files/bash/.bash_profile stowed-files/bash/.aliases \
	$(wildcard stowed-files/*/.local/completion.d/*)

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
	@shellcheck --external-sources $$(grep --directories=skip -lE '^#!.*(bash|/sh)' script/* script/dev/* script/dev/project-template/script/*)
	@shellcheck --external-sources --severity=error --shell=bash $(STARTUP_FILES) \
		$$(grep -rlE '^#!.*(bash|/sh)' stowed-files)
	@shellcheck --severity=error --shell=sh stowed-files/ssh/.ssh/rc

# What the stowed SSH config resolves to for a few hosts, so a misplaced
# Include or Host line shows up
ssh-check:
	@echo "Checking the SSH config..."
	@script/check_ssh_config

test: lint format-check ssh-check
