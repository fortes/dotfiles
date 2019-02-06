# vim: ft=sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Glorious editor
set -o vi

# Make sure we have always loaded ~/.profile, which can get lost
source $HOME/.profile

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Clear C-w binding in order to re-bind in .inputrc
stty werase undef

# Remember a lot of stuff
HISTFILE=$HOME/.bash_history
HISTFILESIZE=5000
HISTSIZE=2000
SAVEHIST=$HISTSIZE
# Don't put duplicate lines into history, ignore commands w/ initial space
HISTCONTROL=ignoreboth:erasedups

# Make sure the terminal type we're using is supported (tmux-256color doesn't
# work everywhere yet)
if ! infocmp $TERM > /dev/null 2>&1; then
  if [[ "$TERM" = "tmux-256color" ]]; then
    export TERM="screen-256color"
  else
    export TERM="xterm-256color"
  fi
fi

# Bash Options {{{
# cd without typing cd
shopt -qs autocd
# Auto-correct directory typos
shopt -qs cdspell
# Check hash before executing
shopt -qs checkhash
# Check for stopped jobs before exiting
shopt -qs checkjobs
# Check window size after each command, and update $LINES and $COLUMNS
shopt -s checkwinsize
# Save all lines of multiline commands
shopt -s cmdhist
# Expand directory names when doing file completion
shopt -qs direxpand
# Fix typos for directories in completion
shopt -qs dirspell
# Include filenames that begin with '.' in filename expansion
shopt -qs dotglob
# Extended pattern matching
shopt -qs extglob
# Allow escape sequencing within ${parameter} expansions
shopt -qs extquote
# Support ** for expansion
shopt -qs globstar
# Append to history list. Allow editing of history substitution in readline
shopt -qs histappend histreedit histverify
# Do hostname completion on words that contain @
shopt -qs hostcomplete
# Don't search path for completions when on an empty line
shopt -s no_empty_cmd_completion
# Case insensitive glob matching and case statements
shopt -s nocaseglob nocasematch
# }}}

BLACK="\[$(tput setaf 0)\]"
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
MAGENTA="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
BOLD="\[$(tput bold)\]"
DIM="\[$(tput dim)\]"
UNDERLINE="\[$(tput smul)\]"
STANDOUT="\[$(tput smso)\]"
RESET="\[$(tput sgr0)\]"

# Hide normal username
if [ `whoami` != 'fortes' ]; then
  BASE_PROMPT="$RED\u@"
else
  BASE_PROMPT=""
fi
# Different host colors for different environments
if [ "$IS_CROUTON" == "1" ]; then
  HOST_COLOR="$MAGENTA"
elif [ "$IS_DOCKER" == "1" ]; then
  HOST_COLOR="$GREEN"
elif [ ! -z "$SSH_TTY" ]; then
  HOST_COLOR="$RED"
else
  HOST_COLOR="$CYAN"
fi

# [user@]host:pwd $
BASE_PROMPT="$BASE_PROMPT$HOST_COLOR\h:$YELLOW\w$RESET"
JOB_COUNT="$BOLD$BLUE[\j]$RESET "
# Write out history after every command. Add job count if non-zero
export PROMPT_COMMAND="history -a; HAS_JOBS=\`jobs -p\` "
PS1="$BASE_PROMPT ""\${HAS_JOBS:+$JOB_COUNT}"

if [ -r /etc/bash_completion.d/git-prompt ]; then
  # Show colored hint about dirty state
  export GIT_PS1_SHOWCOLORHINTS=1
  # Show staged/unstaged changes marker
  export GIT_PS1_SHOWDIRTYSTATE=1
  # Show a $ next to branch name if something stashed
  export GIT_PS1_SHOWSTASHSTATE=1
  # Note untracked files
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  source /etc/bash_completion.d/git-prompt
  export PROMPT_COMMAND="$PROMPT_COMMAND; __git_ps1 \"$BASE_PROMPT\" \" \${HAS_JOBS:+$JOB_COUNT }\" \" %s$RESET\""
fi

# FZF keybindings
sourceIfExists "/usr/share/doc/fzf/examples/key-bindings.bash"

# Load system bash completion
sourceIfExists "/usr/share/bash-completion/bash_completion"
# Load local bash completion
sourceIfExists "$HOME/.local/completions.d/*"
sourceIfExists "$HOME/.local/etc/bash_completion.d/*"

# Load aliases
sourceIfExists "$HOME/.aliases"

# Load local overrides
sourceIfExists "$HOME/.bashrc.local"
