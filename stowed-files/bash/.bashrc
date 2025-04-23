# vim: ft=sh

# If not running interactively, don't do anything here. Anything
# needed in non-interactive shells goes in `.profile`
case $- in
  *i*) ;;
    *) return;;
esac

# Make sure we have always loaded ~/.profile, which can get lost
# shellcheck source=/dev/null
source "$HOME/.profile"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
if [[ -z "${COLORTERM:-}" && "$TERM" =~ "256color" ]]; then
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
export PROMPT_COMMAND="history -a; HAS_JOBS=\$(jobs -sp) "
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

# FZF {{{

# Shell integration for ctrl-t & alt-c
if command_exists fzf; then
  eval "$(fzf --bash)"
fi

fd_command="fd"
if ! command_exists "${fd_command}"; then
  # Debian uses `fdfind`
  fd_command="fdfind"
fi

# Note: --multi set by default here, so need to disable when inappropriate
export FZF_DEFAULT_OPTS_FILE="$HOME/.fzf-default-options"

if command_exists "${fd_command}"; then
  # Use `fd` when available for far better performance
  #
  # $FZF_DEFAULT_COMMAND is executed with `sh -c`, so need to be careful with
  # POSIX compliance
  export FZF_DEFAULT_COMMAND="${fd_command} --type file --hidden --color always"
  export FZF_ALT_C_COMMAND="${fd_command} --type directory --hidden --color always"
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi

export FZF_ALT_C_OPTS="\
  --ghost 'Select directory' \
  --keep-right \
  --no-multi \
  --preview 'fzf-directory-preview {}' \
  --preview-window 'right:25%' \
"

export FZF_CTRL_T_OPTS=" \
  --ghost 'Select file(s)' \
  --keep-right \
  --preview 'fzf-file-preview {}' \
"

# }}}

if command_exists fnm; then
  eval "$(fnm env)"
fi

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
