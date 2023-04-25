# vim:ft=sh

# Add path if not present
add_to_path() {
  if echo ":$PATH:" | grep -vq ":$@:"; then
    export PATH="$@:$PATH"
  fi
}
export -f add_to_path

# Source file only if it exists
source_if_exists() {
  for file in $@; do
    if [[ -f "${file}" ]]; then
      . "${file}"
    elif [[ -d "${file}" ]]; then
      for f in $(find "${file}" -type f); do
        . "${f}"
      done
    fi
  done
}
export -f source_if_exists

# Check for command in path
command_exists() {
  command -v "$1" &> /dev/null
}
export -f command_exists

is_inside_git_repo() {
  git rev-parse --is-inside-work-tree &> /dev/null
}
export -f is_inside_git_repo

fd_with_git() {
  # Show hidden files only when in a git repository
  fdfind --type file --follow \
    $(is_inside_git_repo && echo . "$(git rev-parse --show-cdup)" --hidden) $@
}
export -f fd_with_git

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

fzf_preview_command=""
if command_exists batcat; then
  fzf_preview_command="--preview 'batcat --color always --style=grid,changes --line-range :300 {}'"
else
  fzf_preview_command="--preview 'cat {}'"
fi

# $FZF_DEFAULT_COMMAND is executed with `sh -c`, so need to be careful with
# POSIX compliance
if command_exists fdfind; then
  # Use `fd` when possible for far better performance
  export FZF_DEFAULT_COMMAND='bash -c "fdfind --type file --follow . \$(git rev-parse --show-cdup 2>/dev/null && echo --hidden)"'
  export FZF_CTRL_T_COMMAND='fd_with_git --color always'
fi
export FZF_DEFAULT_OPTS="--height 60% --extended --bind ctrl-alt-a:select-all,ctrl-alt-d:deselect-all,F1:toggle-preview"
export FZF_CTRL_T_OPTS="--ansi --preview-window 'right:50%' $fzf_preview_command"
# Case insensitive by default
export FZF_COMPLETION_OPTS='-i'

if command_exists fnm; then
  eval "$(fnm env)"
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
