# vim:ft=sh

# Add path if not present
add_to_path() {
  if echo ":$PATH:" | grep -vq ":$*:"; then
    export PATH="$*:$PATH"
  fi
}
export -f add_to_path

# Source file only if it exists
source_if_exists() {
  for file in "$@"; do
    if [[ -f "${file}" ]]; then
      # shellcheck source=/dev/null
      . "${file}"
    elif [[ -d "${file}" ]]; then
      while IFS= read -r -d $'\0' f; do
        # shellcheck source=/dev/null
        . "${f}"
      done < <(find "${file}" -type f -print0)
    fi
  done
}
export -f source_if_exists

# Check for command in path
command_exists() {
  command -v "$1" &> /dev/null
}
export -f command_exists

if [[ -n "${LISTENBRAINZ_AUTH_TOKEN:-}" ]]; then
  # scrobbling requires `pylistenbrainz`, not available in Debian so need venv
  source_if_exists "$HOME/.local/venv/bin/activate"
fi

# Use local NeoVim if we have it
if [[ -x "$HOME/.local/bin/nvim" ]]; then
  VISUAL="$HOME/.local/bin/nvim"
elif command_exists nvim; then
  VISUAL="$(command -v nvim)"
elif command_exists vim; then
  VISUAL="$(command -v vim)"
fi

if [[ -n ${VISUAL:-} ]]; then
  EDITOR="$VISUAL"
  export EDITOR VISUAL
fi

# Locally-installed packages belong in path
add_to_path "$HOME/.local/bin"

# Make sure to use system for virsh by default
export LIBVIRT_DEFAULT_URI="qemu:///system"

if [ -z "${XDG_CONFIG_HOME:-}" ]; then
  export XDG_CONFIG_HOME="$HOME/.config"
fi

if [ -z "${XDG_DOWNLOAD_DIR:-}" ]; then
  if [ -d "$HOME/downloads" ]; then
    export XDG_DOWNLOAD_DIR="$HOME/downloads"
  elif [ -d "$HOME/Downloads" ]; then
    export XDG_DOWNLOAD_DIR="$HOME/Downloads"
  fi
fi

# Rg, for whatever reason, needs to manually specify location for config
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/rc"

if [ -z "${SSH_AUTH_SOCK:-}" ] && command_exists keychain; then
  # Don't prompt for password to load id_rsa if not already loaded
  eval "$(keychain --eval --noask --agents ssh --quiet)"

  SSH_SOCKET_LOCATION="$HOME/.ssh/ssh_auth_sock"
  if [ ! -S "${SSH_SOCKET_LOCATION}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
    ln -sf "${SSH_AUTH_SOCK}" "${SSH_SOCKET_LOCATION}"
  fi
fi

# Local overrides
source_if_exists "$HOME/.profile.local"
