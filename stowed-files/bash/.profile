# vim:ft=sh

# Use NeoVim if we have it
if command -v nvim > /dev/null; then
  VISUAL=nvim
else
  VISUAL=vim
fi
EDITOR=$VISUAL
export EDITOR VISUAL

# If available, we use git to list files from the root directory (not from the
# current directory as in other fzf cases). Otherwise, fallback to fd
# shellcheck disable=SC2016
export FZF_DEFAULT_COMMAND='(git ls-files -co --exclude-standard $(git rev-parse --show-toplevel) || fdfind --type file --color always) 2> /dev/null'
export FZF_DEFAULT_OPTS="--extended --bind alt-a:select-all,alt-d:deselect-all --ansi --preview-window 'right:60%' --preview 'bat --color always --style='grid,changes' --line-range :300 {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Case insensitive by default
export FZF_COMPLETION_OPTS='-i'

if [ -z "$XDG_CONFIG_HOME" ]; then
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
fi

# Locally-installed packages belong in path
if echo ":$PATH:" | grep -vq ":$HOME/.local/bin:"; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Use local directory for n
export N_PREFIX="$HOME/.local"

# cargo
export CARGO_HOME="$HOME/.local/cargo"
if echo ":$PATH:" | grep -vq ":$HOME/.local/cargo/bin:"; then
  export PATH="$HOME/.local/cargo/bin:$PATH"
fi

# pyenv setup
export PYENV_VERSION="3.7.3"
export PYENV_ROOT="$HOME/.local/pyenv"
if echo ":$PATH:" | grep -vq "$PYENV_ROOT/bin:"; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv > /dev/null; then
  eval "$(pyenv init -)"
  # Enable auto-activation for virtualenv
  eval "$(pyenv virtualenv-init -)"
fi

# Use ag for faster default find command for listing candidates
if [ -d "$HOME/.local/source/fzf/" ]; then
  _fzf_compgen_path() {
    ag -g "" "$1"
  }
fi

# Helper function for sourcing a file only if it exists
function sourceIfExists() {
  for file in $@; do
    if [ -f "$file" ]; then
      source "$file"
    fi
  done
}

export -f sourceIfExists

if command -v keychain &>/dev/null; then
  # Don't prompt for password to load id_rsa if not already loaded
  eval "$(keychain --eval --noask --agents ssh --quiet)"
else
  sourceIfExists "$HOME/.ssh/start_agent.sh"
fi

# Local overrides
sourceIfExists "$HOME/.profile.local"
