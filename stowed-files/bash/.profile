# vim:ft=sh

# Add path if not present
addToPath() {
  if echo ":$PATH:" | grep -vq ":$@:"; then
    export PATH="$@:$PATH"
  fi
}
export -f addToPath

# Source file only if it exists
sourceIfExists() {
  for file in $@; do
    [ -f "$file" ] && . "$file"
  done
}
export -f sourceIfExists

# Check for command in path
commandExists() {
  command -v "$1" &> /dev/null
}
export -f commandExists

# Use NeoVim if we have it
if commandExists nvim; then
  VISUAL=nvim
else
  VISUAL=vim
fi
EDITOR="$VISUAL"
export EDITOR VISUAL

# Locally-installed packages belong in path
addToPath "$HOME/.local/bin"

# Defaults to "$HOME/.local/bin", avoid running since it slows shell creation
# if commandExists yarnpkg; then
#   addToPath "$(yarnpkg global bin)"
# fi

# Make sure to use system for virsh by default
export LIBVIRT_DEFAULT_URI="qemu:///system"

isInsideGitRepo() {
  git rev-parse --is-inside-work-tree &> /dev/null
}
export -f isInsideGitRepo

gitAwareFd() {
  # Show hidden files only when in a git repository
  fdfind --type file --follow \
    $(isInsideGitRepo && echo . "$(git rev-parse --show-cdup)" --hidden) $@
}
export -f gitAwareFd

bat_preview_command=""
if commandExists bat; then
  bat_preview_command="--preview 'bat --color always --style=grid,changes --line-range :300 {}'"
fi

# $FZF_DEFAULT_COMMAND is executed with `sh -c`, so need to be careful with
# POSIX compliance
export FZF_DEFAULT_COMMAND='bash -c "fdfind --type file --follow . \$(git rev-parse --show-cdup 2>/dev/null && echo --hidden)"'
export FZF_DEFAULT_OPTS="--height 40% --extended --bind ctrl-alt-a:select-all,ctrl-alt-d:deselect-all,F1:toggle-preview"
export FZF_CTRL_T_COMMAND='gitAwareFd --color always'
export FZF_CTRL_T_OPTS="--ansi --preview-window 'right:50%' $bat_preview_command"
# Case insensitive by default
export FZF_COMPLETION_OPTS='-i'

if [ -z "$XDG_CONFIG_HOME" ]; then
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
fi

if [ -z "$SSH_AUTH_SOCK" ] && commandExists keychain; then
  # Don't prompt for password to load id_rsa if not already loaded
  eval "$(keychain --eval --noask --agents ssh --quiet)"
fi

# Local overrides
sourceIfExists "$HOME/.profile.local"
