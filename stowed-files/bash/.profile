# vim:ft=sh

# Add path if not present
add_to_path() {
  if [[ ":${PATH}:" != *":$*:"* ]]; then
    export PATH="$*:$PATH"
  fi
}

# Source file only if it exists
source_if_exists() {
  local file f
  for file in "$@"; do
    if [[ -f "${file}" ]]; then
      # shellcheck source=/dev/null
      . "${file}"
    elif [[ -d "${file}" ]]; then
      for f in "${file}"/*; do
        if [[ -f "${f}" && "${f##*/}" != .* ]]; then
          # shellcheck source=/dev/null
          . "${f}"
        fi
      done
    fi
  done
}

# Check for command in path
command_exists() {
  command -v "$1" &>/dev/null
}

# Homebrew paths, etc. Before picking an editor, so Homebrew nvim counts
source_if_exists "$HOME/.profile.brew"

# Locally-installed packages belong in path
add_to_path "$HOME/.local/bin"

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

export PNPM_HOME="${HOME}/.local/share/pnpm"
# Where `pnpm add --global` links binaries: $PNPM_HOME/bin in newer pnpm (12
# does), the directory itself in older ones. pnpm refuses global installs when
# it's not on PATH
add_to_path "${PNPM_HOME}"
add_to_path "${PNPM_HOME}/bin"
# Corepack otherwise asks before fetching a project's pnpm or Yarn, which
# leaves agents' commands hanging
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

# Keep bun's cache and any globals under ~/.local
export BUN_INSTALL="${HOME}/.local"

# With the MPD setup, beets reads the copy of the server's library that
# mpd-sync keeps, so play-albums and any `beet` command agree. A server with
# its own library sets BEETSDIR in ~/.profile.local, which comes later
if [[ -d "$HOME/.mpd" ]]; then
  export BEETSDIR="$HOME/.mpd/beets"
fi

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

# Opt-out of telemetry
export DO_NOT_TRACK=true
export ET_NO_TELEMETRY=1
export GH_TELEMETRY=false

# Rg, for whatever reason, needs to manually specify location for config
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/rc"

# Syntax colors from the terminal's palette (base16 layout, as in Ghostty's
# theme), for bat and delta
export BAT_THEME="base16-256"

if [ -z "${SSH_AUTH_SOCK:-}" ] && command_exists keychain; then
  # Don't prompt for password to load key if not already loaded. Starts only
  # ssh-agent by default; keychain 3 deprecated --agents and warns about it
  eval "$(keychain --eval --noask --quiet)"

  # Use consistent location for SSH_AUTH_SOCK, useful for tmux sessions where
  # can end up on different machines, or reconnecting to a session
  SSH_SOCKET_LOCATION="$HOME/.ssh/ssh_auth_sock"
  mkdir -p "$(dirname "${SSH_SOCKET_LOCATION}")"
  if [ ! -S "${SSH_SOCKET_LOCATION}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
    ln -sf "${SSH_AUTH_SOCK}" "${SSH_SOCKET_LOCATION}" \
      || echo "Warning: Failed to symlink SSH_AUTH_SOCK to ${SSH_SOCKET_LOCATION}"
  fi
fi

if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
  export IS_DOCKER=1
fi
source_if_exists "$HOME/.profile.local"
