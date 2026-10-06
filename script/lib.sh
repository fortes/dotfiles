#!/usr/bin/env bash
# Shared library functions for scripts
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# For helpers below that run other scripts from here
dotfiles_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure ~/.local/bin is in PATH for locally-installed tools
export PATH="$HOME/.local/bin:$PATH"

# Installers must work before stow and from shells that never read .profile.
[[ ! -x /opt/homebrew/bin/brew ]] || export PATH="/opt/homebrew/bin:$PATH"
export NPM_CONFIG_PREFIX="$HOME/.local"
export CARGO_HOME="$HOME/.local/share/cargo"
export CARGO_INSTALL_ROOT="$HOME/.local"
export BUN_INSTALL="$HOME/.local"

# Shared by setup and update so they select the same scope.
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

# Whether a stow package is listed in the space-separated
# DOTFILES_SKIP_PACKAGES. Only applies when stowing everything: packages named
# explicitly get stowed anyway
is_skipped_package() {
  [[ " ${DOTFILES_SKIP_PACKAGES:-} " == *" $1 "* ]]
}

# Print the stow packages in the given directory, one per line, minus any
# skipped ones
list_stow_packages() {
  local package_path package
  for package_path in "$1"/*/; do
    [[ -d "${package_path}" ]] || continue
    package="$(basename "${package_path}")"
    is_skipped_package "${package}" || echo "${package}"
  done
}

# Startup files that Debian (.bashrc, .profile) and macOS (.bash_profile)
# provide by default, which conflict with the bash package
DEFAULT_DOTFILES=(.bashrc .profile .bash_profile)

# Whether a startup file in $HOME is machine-provided and would block stow:
# a regular file, or a symlink that doesn't point into a stowed-files dir
is_default_dotfile() {
  local -r path="${HOME}/$1"
  if [[ -L "${path}" ]]; then
    [[ "$(readlink "${path}")" != *stowed-files/* ]]
  else
    [[ -f "${path}" ]]
  fi
}

# Back up machine-provided startup files before stowing. If stow fails,
# fix the conflict and rerun, or restore the files from the printed directory.
stow_with_backup() {
  local filename backup_dir=''
  if ! is_skipped_package bash; then
    for filename in "${DEFAULT_DOTFILES[@]}"; do
      is_default_dotfile "${filename}" || continue
      if [[ -z "${backup_dir}" ]]; then
        backup_dir="$(mktemp -d "$HOME/.dotfiles-backup.XXXXXX")" || return 1
        echo "Startup-file backup: ${backup_dir} (restore manually if needed)"
      fi
      mv "$HOME/${filename}" "${backup_dir}/original${filename}" || return 1
    done
  fi
  "${dotfiles_script_dir}/stow" -R
}
