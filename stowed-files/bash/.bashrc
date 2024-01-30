# vim: ft=sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Glorious editor
set -o vi

# Make sure we have always loaded ~/.profile, which can get lost
# shellcheck source=/dev/null
source "$HOME/.profile"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Clear C-w binding in order to re-bind in .inputrc
stty werase undef

HISTFILE=$HOME/.bash_history
# Never forget
HISTFILESIZE=-1
HISTSIZE=-1
# Don't put duplicate lines into history, ignore commands w/ initial space
HISTCONTROL=ignoreboth:erasedups

# Make sure the terminal type we're using is supported (tmux-256color doesn't
# work everywhere yet)
if ! infocmp "${TERM}" > /dev/null 2>&1; then
  if [[ "${TERM}" = "tmux-256color" ]]; then
    export TERM="screen-256color"
  else
    export TERM="xterm-256color"
  fi
fi

# In these modern times, if 256 colors are supported, truecolor probably is too
if [[ -z "${COLORTERM:-}" ]] && [[ "$TERM" =~ "256color" ]]; then
  export COLORTERM="truecolor"
fi

# Bash Options {{{
# cd without typing cd (unsupported in Mac version)
shopt -qs autocd 2> /dev/null || true
# Auto-correct directory typos
shopt -qs cdspell
# Check hash before executing
shopt -qs checkhash
# Check for stopped jobs before exiting (unsupported in Mac version)
shopt -qs checkjobs 2> /dev/null || true
# Check window size after each command, and update $LINES and $COLUMNS
shopt -qs checkwinsize
# Save all lines of multiline commands
shopt -qs cmdhist
# Expand directory names when doing file completion (unsupported in Mac version)
shopt -qs direxpand 2> /dev/null || true
# Fix typos for directories in completion (unsupported in Mac version)
shopt -qs dirspell 2> /dev/null || true
# Include filenames that begin with '.' in filename expansion
shopt -qs dotglob
# Extended pattern matching
shopt -qs extglob
# Allow escape sequencing within ${parameter} expansions
shopt -qs extquote
# Support ** for expansion (unsupported in Mac version)
shopt -qs globstar 2> /dev/null || true
# Append to history list. Allow editing of history substitution in readline
shopt -qs histappend histreedit histverify
# Do hostname completion on words that contain @
shopt -qs hostcomplete
# Don't search path for completions when on an empty line
shopt -qs no_empty_cmd_completion
# Case insensitive glob matching and case statements
shopt -qs nocaseglob nocasematch
# Expand aliases in order to find completions
shopt -qs progcomp_alias
# }}}

# shellcheck disable=SC2034
BLACK="\[$(tput setaf 0)\]"
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
# shellcheck disable=SC2034
MAGENTA="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
# shellcheck disable=SC2034
WHITE="\[$(tput setaf 7)\]"
BOLD="\[$(tput bold)\]"
# shellcheck disable=SC2034
DIM="\[$(tput dim)\]"
# shellcheck disable=SC2034
UNDERLINE="\[$(tput smul)\]"
# shellcheck disable=SC2034
STANDOUT="\[$(tput smso)\]"
RESET="\[$(tput sgr0)\]"

# Hide normal username
if [ "$(whoami)" != 'fortes' ]; then
  BASE_PROMPT="$RED\u@"
else
  BASE_PROMPT=""
fi
# Different host colors for different environments
if [ "$IS_DOCKER" == "1" ]; then
  HOST_COLOR="$GREEN"
elif [[ -n "$SSH_TTY" && -n "$ET_VERSION" && -z "$IS_DOCKER" ]]; then
  HOST_COLOR="$RED"
else
  HOST_COLOR="$CYAN"
fi

# [[user@]host]:pwd $
if [[ -z "$SSH_TTY" && -z "$ET_VERSION" && -z "$IS_DOCKER" ]]; then
  BASE_PROMPT="${BASE_PROMPT}${YELLOW}\w${RESET}"
else
  BASE_PROMPT="${BASE_PROMPT}${HOST_COLOR}\h:${YELLOW}\w${RESET}"
fi
JOB_COUNT="${BOLD}${BLUE}[\j]${RESET} "
# Write out history after every command. Add job count if non-zero stopped
export PROMPT_COMMAND="history -a; HAS_JOBS=\`jobs -sp\` "
PS1="$BASE_PROMPT ""\${HAS_JOBS:+$JOB_COUNT}"

git_prompt_location="/etc/bash_completion.d/git-prompt"
if [ ! -r "${git_prompt_location}" ]; then
  # Homebrew
  git_prompt_location="/opt/homebrew/etc/bash_completion.d/git-prompt.sh"
fi

if [ -r "${git_prompt_location}" ]; then
  # Show colored hint about dirty state
  export GIT_PS1_SHOWCOLORHINTS=1
  # Show staged/unstaged changes marker
  export GIT_PS1_SHOWDIRTYSTATE=1
  # Note untracked files
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  # Suppress prompt when within an ignored dir
  export GIT_PS1_HIDE_IF_PWD_IGNORED=1
  # shellcheck source=/dev/null
  source "${git_prompt_location}"
  export PROMPT_COMMAND="$PROMPT_COMMAND; __git_ps1 \"$BASE_PROMPT\" \" \${HAS_JOBS:+$JOB_COUNT }\" \" %s$RESET\""
fi

if command_exists dircolors; then
  if [[ -r "$HOME/.dircolors" ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi

if command_exists zoxide; then
  eval "$(zoxide init bash --hook pwd)"
fi

FD_COMMAND="fd"
if ! command_exists "${FD_COMMAND}"; then
  # Debian uses `fdfind`
  FD_COMMAND="fdfind"
fi
export FD_COMMAND

BAT_COMMAND="bat"
if ! command_exists "${BAT_COMMAND}"; then
  # Debian uses `fdfind`
  BAT_COMMAND="batcat"
fi
export BAT_COMMAND

fzf_preview_command=""
if command_exists pistol; then
  fzf_preview_command="'pistol {}'"
elif command_exists "${BAT_COMMAND}"; then
  fzf_preview_command="'${BAT_COMMAND} --color always --style=grid,changes --line-range :300 {}'"
else
  fzf_preview_command="'cat {}'"
fi

if command_exists "${FD_COMMAND}"; then
  # Use `fd` when possible for far better performance
  #
  # $FZF_DEFAULT_COMMAND is executed with `sh -c`, so need to be careful with
  # POSIX compliance
  export FZF_DEFAULT_COMMAND="fd_with_git"
  export FZF_CTRL_T_COMMAND="fd_with_git"
  export FZF_ALT_C_COMMAND="${FD_COMMAND} --type directory --hidden --color always"
fi
if command_exists exa; then
  # Show tree structure in preview window
  export FZF_ALT_C_OPTS="
    --preview 'exa -T -a {}'
    "
fi
export FZF_DEFAULT_OPTS="
  --ansi
  --bind 'ctrl-alt-a:select-all'
  --bind 'ctrl-alt-d:deselect-all'
  --extended
  --inline-info
  "
# Alt-C to choose directory file lives in
export FZF_CTRL_T_OPTS="
  --bind 'alt-c:execute(echo -n {} | xargs dirname)+abort'
  --preview ${fzf_preview_command}
  --preview-window 'right:50%'
  "
export FZF_COMPLETION_OPTS='--smart-case'

# Use wayland for Firefox
export MOZ_ENABLE_WAYLAND=1

# FZF keybindings (Debian)
source_if_exists "/usr/share/doc/fzf/examples/key-bindings.bash"
# FZF keybindings (Homebrew)
source_if_exists "/opt/homebrew/opt/fzf/shell/key-bindings.bash"

if command_exists fnm; then
  eval "$(fnm env)"
fi

# Opt-out of Eternal Terminal telemetry
export ET_NO_TELEMETRY=1

# Load system bash completion
source_if_exists "/etc/bash_completion"
# Load Homebrew bash completion, see https://docs.brew.sh/Shell-Completion
source_if_exists "/opt/homebrew/etc/profile.d/bash_completion.sh"
source_if_exists "/opt/homebrew/etc/bash_completion.d"
source_if_exists "/opt/homebrew/share/bash-completion/bash_completion"

# Load local bash completion
source_if_exists "$HOME/.local/completion.d"

# Load aliases
source_if_exists "$HOME/.aliases"

# Load local overrides
source_if_exists "$HOME/.bashrc.local"
