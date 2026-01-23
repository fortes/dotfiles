# vim:ft=sh

# Add path if not present
add_to_path() {
  if ! echo ":$PATH:" | grep -q ":$*:"; then
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
      done < <(find "${file}" -maxdepth 2 -type f -print0)
    fi
  done
}
export -f source_if_exists

# Check for command in path
command_exists() {
  command -v "$1" &> /dev/null
}
export -f command_exists

# Use local NeoVim if we have it
if [[ -x "$HOME/.local/bin/nvim" ]]; then
  VISUAL="$HOME/.local/bin/nvim"
elif command_exists nvim; then
  VISUAL="nvim"
elif command_exists vim; then
  VISUAL="vim"
fi

if [[ -n ${VISUAL:-} ]]; then
  EDITOR="$VISUAL"
  export EDITOR VISUAL
fi

# Homebrew paths, etc
source_if_exists "$HOME/.profile.brew"

# Locally-installed packages belong in path
add_to_path "$HOME/.local/bin"

# Node versions
if command_exists fnm; then
  eval "$(fnm env)"
fi

# pnpm global packages
export PNPM_HOME="${HOME}/.local/share/pnpm"
add_to_path "${PNPM_HOME}"

export CARGO_HOME="${HOME}/.local/share/cargo"
# Cargo packages install to ~/.local/bin
export CARGO_INSTALL_ROOT="${HOME}/.local"

# Use NeoVim as man pager, when available
if command_exists nvim; then
  export MANPAGER="nvim +Man!"
fi

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

# Opt-out of Eternal Terminal telemetry
export ET_NO_TELEMETRY=1

# Make sure to use system for virsh by default
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Use wayland for Firefox
export MOZ_ENABLE_WAYLAND=1

# Rg, for whatever reason, needs to manually specify location for config
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/rc"

if [ -z "${SSH_AUTH_SOCK:-}" ] && command_exists keychain; then
  # Don't prompt for password to load key if not already loaded
  eval "$(keychain --eval --noask --agents ssh --quiet)"

  # Use consistent location for SSH_AUTH_SOCK, useful for tmux sessions where
  # can end up on different machines, or reconnecting to a session
  SSH_SOCKET_LOCATION="$HOME/.ssh/ssh_auth_sock"
  mkdir -p "$(dirname "${SSH_SOCKET_LOCATION}")"
  if [ ! -S "${SSH_SOCKET_LOCATION}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
    ln -sf "${SSH_AUTH_SOCK}" "${SSH_SOCKET_LOCATION}" || \
      echo "Warning: Failed to symlink SSH_AUTH_SOCK to ${SSH_SOCKET_LOCATION}"
  fi
fi

# Local overrides
source_if_exists "$HOME/.profile.local"
