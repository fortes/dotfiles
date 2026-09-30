#!/usr/bin/env bash
# Shared library functions for scripts
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# For helpers below that run other scripts from here
dotfiles_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure ~/.local/bin is in PATH for locally-installed tools
export PATH="$HOME/.local/bin:$PATH"

# Helper function to check if command exists
command_exists() {
  command -v "$1" &>/dev/null
}

echo_stderr() {
  >&2 echo "${@}"
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

# Restow every package, or just the given one. Machine-provided startup files
# conflict with the bash package, so they're moved into a unique
# ~/.dotfiles-backup.* dir first and put back if stow fails. Rerunning
# recovers from anything else, like an interruption
stow_with_backup() {
  local -r package="${1:-}"
  local filename backup_dir=''
  # No package means all of them, minus the same skip list script/stow uses
  if [[ "${package}" == bash ]] || { [[ -z "${package}" ]] && ! is_skipped_package bash; }; then
    for filename in "${DEFAULT_DOTFILES[@]}"; do
      is_default_dotfile "${filename}" || continue
      # Only made once there's something to move
      if [[ -z "${backup_dir}" ]]; then
        backup_dir="$(mktemp -d "${HOME}/.dotfiles-backup.XXXXXX")" || return 1
      fi
      echo "Moving default ${filename} to ${backup_dir}"
      if ! mv "${HOME}/${filename}" "${backup_dir}/original${filename}"; then
        restore_default_dotfiles "${backup_dir}"
        return 1
      fi
    done
  fi

  if ! "${dotfiles_script_dir}/stow" -R ${package:+"${package}"}; then
    if [[ -n "${backup_dir}" ]]; then
      restore_default_dotfiles "${backup_dir}"
    fi
    return 1
  fi
  if [[ -n "${backup_dir}" ]]; then
    echo "Original startup files saved in ${backup_dir}"
  fi
}

# Move startup files from a failed stow_with_backup back into any spots stow
# left empty, then drop the dir if nothing is left in it
restore_default_dotfiles() {
  local -r backup_dir=$1
  local filename backup status=0
  for filename in "${DEFAULT_DOTFILES[@]}"; do
    backup="${backup_dir}/original${filename}"
    if [[ ! -e "${HOME}/${filename}" && ! -L "${HOME}/${filename}" ]] \
      && [[ -e "${backup}" || -L "${backup}" ]]; then
      echo_stderr "Restoring original ${filename}"
      # Keep going, so one failure doesn't leave the other files missing too
      mv "${backup}" "${HOME}/${filename}" || status=1
    fi
  done
  if ! rmdir "${backup_dir}" 2>/dev/null; then
    echo "Original startup files saved in ${backup_dir}"
  fi
  return "${status}"
}

# Generate ~/.profile.local unless it already exists, via a temp file so a
# failure doesn't leave a partial file behind
ensure_local_profile() {
  local -r local_profile_path="${HOME}/.profile.local"
  [[ -f "${local_profile_path}" ]] && return 0

  echo "Generating ${local_profile_path}"
  if ! "${dotfiles_script_dir}/create_local_profile" >"${local_profile_path}.tmp"; then
    rm -f "${local_profile_path}.tmp"
    return 1
  fi
  mv "${local_profile_path}.tmp" "${local_profile_path}"
}
