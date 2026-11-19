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
# Like ~/.npmrc's, for machines and builds that haven't stowed it
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export BUN_INSTALL="$HOME/.local"

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

# Install apt packages (or .deb paths). dpkg ignores -qq and prints four lines
# per package, so its stdout goes to a log; errors and warnings stay on stderr,
# and a failure prints the log's end
apt_install() {
  local IFS=' ' log="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/apt-install.log"
  mkdir -p "$(dirname "${log}")"
  echo "=== $(date) apt-get install $*" >>"${log}"
  # So a failure shows only this install's output
  local start
  start="$(wc -l <"${log}")"
  # Keep edited config files without asking: the question would go to the log,
  # leaving setup waiting on an answer nobody sees
  # shellcheck disable=SC2024 # The log is yours, so the redirect skips sudo
  if ! DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -qq --assume-yes \
    --fix-broken --no-install-recommends -o=Dpkg::Use-Pty=0 \
    -o=Dpkg::Options::=--force-confdef -o=Dpkg::Options::=--force-confold \
    -o=Dpkg::Progress-Fancy=0 -o=APT::Get::Show-Progress=false "$@" >>"${log}"; then
    tail -n "+$((start + 1))" "${log}" | tail -n 20 >&2
    echo_stderr "apt-get install failed; full output in ${log}"
    return 1
  fi
}
