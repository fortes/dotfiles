#!/usr/bin/env bash
# Shared library functions for scripts
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Used by callers that run other scripts from here
# shellcheck disable=SC2034
dotfiles_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure ~/.local/bin is in PATH for locally-installed tools
export PATH="$HOME/.local/bin:$PATH"

# Installers must work before stow and from shells that never read .profile.
[[ ! -x /opt/homebrew/bin/brew ]] || export PATH="/opt/homebrew/bin:$PATH"
export NPM_CONFIG_PREFIX="$HOME/.local"
export CARGO_HOME="$HOME/.local/share/cargo"
export CARGO_INSTALL_ROOT="$HOME/.local"
export BUN_INSTALL="$HOME/.local"

# Shared by setup_devbox and update; setup_devbox derives the binary names
# shellcheck disable=SC2034
DEVBOX_GITHUB_PACKAGES=(fzf marksman neovim tree-sitter-cli yq)

# Shared by setup and update so they select the same scope
is_devbox() {
  [[ "${DOTFILES_DEVBOX:-}" == 1 ]] \
    || grep -qE '^ID="?ubuntu"?$' /etc/os-release 2>/dev/null
}

# Helper function to check if command exists
command_exists() {
  command -v "$1" &>/dev/null
}

echo_stderr() {
  echo >&2 "${@}"
}
