# vim:ft=sh

# Use NeoVim if we have it
if command -v nvim > /dev/null; then
  VISUAL=nvim
else
  VISUAL=vim
fi
EDITOR=$VISUAL
export EDITOR VISUAL

# Add path if not present
addToPath() {
  if echo ":$PATH:" | grep -vq ":$@:"; then
    export PATH="$@:$PATH"
  fi
}
export -f addToPath

# Helper function for sourcing a file only if it exists
sourceIfExists() {
  for file in $@; do
    [ -f "$file" ] && . "$file"
  done
}
export -f sourceIfExists

commandExists() {
  command -v "$1" &> /dev/null
}
export -f commandExists

# Locally-installed packages belong in path
addToPath "$HOME/.local/bin"

# Use local directory for n
export N_PREFIX="$HOME/.local"

# cargo
export CARGO_HOME="$HOME/.local/cargo"
addToPath "$HOME/.local/cargo/bin"

# pyenv setup
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.local/pyenv"
addToPath "$PYENV_ROOT/bin"

# shellcheck disable=SC2016
fd_command='fdfind --type file --follow --hidden'
bat_preview_command=""
if commandExists bat; then
  bat_preview_command="--preview 'bat --color always --style=grid,changes --line-range :300 {}'"
fi

# Use git if available
export FZF_DEFAULT_COMMAND='(
  git ls-files -co --exclude-standard || "$fd_command"
) 2> /dev/null'
export FZF_DEFAULT_OPTS="--extended --bind ctrl-alt-a:select-all,ctrl-alt-d:deselect-all"
export FZF_CTRL_T_COMMAND="$fd_command --color always"
export FZF_CTRL_T_OPTS="--ansi --preview-window 'right:50%' $bat_preview_command"

# Case insensitive by default
export FZF_COMPLETION_OPTS='-i'

if [ -z "$XDG_CONFIG_HOME" ]; then
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
fi

if commandExists pyenv; then
  eval "$(pyenv init -)"
  # Enable auto-activation for virtualenv
  eval "$(pyenv virtualenv-init -)"
fi

if commandExists keychain; then
  # Don't prompt for password to load id_rsa if not already loaded
  eval "$(keychain --eval --noask --agents ssh --quiet)"
fi

# Local overrides
sourceIfExists "$HOME/.profile.local"
