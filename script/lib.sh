#!/usr/bin/env bash
# Shared library functions for scripts
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Ensure ~/.local/bin is in PATH for locally-installed tools
export PATH="$HOME/.local/bin:$PATH"

# Helper function to check if command exists
command_exists() {
  command -v "$1" &>/dev/null
}

echo_stderr() {
  >&2 echo "${@}"
}

# Print the stow packages in the given directory, one per line, minus any
# listed in the space-separated DOTFILES_SKIP_PACKAGES
list_stow_packages() {
  local package_path package
  for package_path in "$1"/*/; do
    [[ -d "${package_path}" ]] || continue
    package="$(basename "${package_path}")"
    if [[ " ${DOTFILES_SKIP_PACKAGES:-} " != *" ${package} "* ]]; then
      echo "${package}"
    fi
  done
}
