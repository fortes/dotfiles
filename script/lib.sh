#!/usr/bin/env bash
# Shared library functions for scripts
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Ensure ~/.local/bin is in PATH for locally-installed tools
export PATH="$HOME/.local/bin:$PATH"

# Helper function to check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}
