# vim: ft=sh

# If not running interactively, don't do anything here. Anything
# needed in non-interactive shells goes in `.profile`
case $- in
  *i*) ;;
  *) return ;;
esac

# Make sure we have always loaded ~/.profile, which can get lost
# shellcheck source=/dev/null
source "$HOME/.profile"

# Debian's lesspipe just prints these exports when called without arguments.
if [ -x /usr/bin/lesspipe ]; then
  export LESSOPEN='| /usr/bin/lesspipe %s'
  export LESSCLOSE='/usr/bin/lesspipe %s %s'
fi

# Not the default ~/.bash_history, which any shell that skips this file (`bash
# --norc`) cuts back to 500 lines on exit. Dev containers keep it in /state so
# it survives a rebuild
if [[ -n "${DOTFILES_DEV_IMAGE:-}" ]]; then
  HISTFILE=/state/bash_history
else
  HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
  [[ -d "${HISTFILE%/*}" ]] || mkdir -p "${HISTFILE%/*}"
fi
# Never forget
HISTFILESIZE=-1
HISTSIZE=-1
# Don't put duplicate lines into history, ignore commands w/ initial space
HISTCONTROL=ignoreboth
# Save when each command ran, and show it in `history`
HISTTIMEFORMAT='%F %T '

# Make sure the terminal type we're using is supported (tmux-256color doesn't
# work everywhere yet)
if ! infocmp "${TERM}" >/dev/null 2>&1; then
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
shopt -qs autocd 2>/dev/null || true
# Auto-correct directory typos
shopt -qs cdspell
# Check hash before executing
shopt -qs checkhash
# Check for stopped jobs before exiting (unsupported in Mac version)
shopt -qs checkjobs 2>/dev/null || true
# Check window size after each command, and update $LINES and $COLUMNS
shopt -qs checkwinsize
# Save all lines of multiline commands
shopt -qs cmdhist
# Expand directory names when doing file completion (unsupported in Mac version)
shopt -qs direxpand 2>/dev/null || true
# Fix typos for directories in completion (unsupported in Mac version)
shopt -qs dirspell 2>/dev/null || true
# Include filenames that begin with '.' in filename expansion
shopt -qs dotglob
# Extended pattern matching
shopt -qs extglob
# Allow escape sequencing within ${parameter} expansions
shopt -qs extquote
# Support ** for expansion (unsupported in Mac version)
shopt -qs globstar 2>/dev/null || true
# Append to history list. Allow editing of history substitution in readline
shopt -qs histappend histreedit histverify
# Do hostname completion on words that contain @
shopt -qs hostcomplete
# Don't search path for completions when on an empty line
shopt -qs no_empty_cmd_completion
# Case insensitive glob matching and case statements
shopt -qs nocaseglob nocasematch
# Expand aliases in order to find completions (unsupported in Mac version)
shopt -qs progcomp_alias 2>/dev/null || true
# }}}

RED='\[\e[31m\]'
YELLOW='\[\e[33m\]'
CYAN='\[\e[36m\]'
DIM='\[\e[2m\]'
BLUE='\[\e[34m\]'
BOLD='\[\e[1m\]'
RESET='\[\e[m\]'

# Hide normal username
if ((EUID == 0)) || [[ "${USER:-$(id -un)}" != "${DEFAULT_USERNAME:-fortes}" ]]; then
  BASE_PROMPT="$RED\u@"
else
  BASE_PROMPT=""
fi
# [[user@]host]:pwd $ (dim cyan host in containers, red over SSH/ET; not
# green, which the git prompt uses for branches)
if [[ "${IS_DOCKER:-}" == "1" ]]; then
  BASE_PROMPT="${BASE_PROMPT}${DIM}${CYAN}\h:${RESET}${YELLOW}\w${RESET}"
elif [[ -n "${SSH_TTY:-}" || -n "${ET_VERSION:-}" ]]; then
  BASE_PROMPT="${BASE_PROMPT}${RED}\h:${YELLOW}\w${RESET}"
else
  BASE_PROMPT="${BASE_PROMPT}${YELLOW}\w${RESET}"
fi
JOB_COUNT="${BOLD}${BLUE}[\j]${RESET} "
EXIT_STATUS="${BOLD}${RED}✗${RESET} "
# After the path: stopped jobs, then the last command's exit code if it failed
PROMPT_SUFFIX="\${HAS_JOBS:+$JOB_COUNT}\${LAST_EXIT:+$EXIT_STATUS}"
# Long paths keep their last three folders (.../src/blog/content)
PROMPT_DIRTRIM=3
# The last command's exit code for the prompt, only when a command ran and
# failed. Not for success, a command that wasn't found or isn't executable
# (127, 126) or Ctrl-C (130), whose messages already say so, nor a suspended
# job (Ctrl-Z gives 128 plus the stop signal's number, which differs between
# Linux and macOS, and the jobs count already shows it)
__prompt_exit() {
  LAST_EXIT="$1"
  if [[ "${LAST_EXIT}" =~ ^(0|126|127|130)$ ]]; then
    LAST_EXIT=
  elif ((LAST_EXIT > 128)) \
    && [[ "$(kill -l $((LAST_EXIT - 128)) 2>/dev/null)" =~ ^(SIG)?(TSTP|STOP|TTIN|TTOU)$ ]]; then
    LAST_EXIT=
  fi
}
# Save the exit code first, before anything else here changes it. Write out
# history after every command. Not exported, since it calls functions child
# shells may not have defined (e.g. `bash --norc`). Un-export in case
# inherited from an older shell
PROMPT_COMMAND="__prompt_exit \$?; history -a; HAS_JOBS=\$(jobs -sp) "
export -n PROMPT_COMMAND
PS1="$BASE_PROMPT $PROMPT_SUFFIX"

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
  PROMPT_COMMAND="$PROMPT_COMMAND; __git_ps1 \"$BASE_PROMPT\" \" $PROMPT_SUFFIX\" \" %s$RESET\""
fi

# Mark prompt and command output starts (OSC 133) so tmux can jump between
# them in copy mode. Ghostty's shell integration handles this outside of tmux
if [[ -n "${TMUX:-}" ]]; then
  __osc133_prompt_start='\[\e]133;A\a\]'
  # Added to PROMPT_COMMAND at the end of this file, so it runs after anything
  # that rebuilds PS1 on every prompt (__git_ps1, hooks in .bashrc.local)
  __osc133_mark_prompt() {
    [[ "$PS1" == "$__osc133_prompt_start"* ]] \
      || PS1="${__osc133_prompt_start}${PS1}"
  }
  [[ "${PS0:-}" == *'133;C'* ]] || PS0="${PS0:-}"'\e]133;C\a'
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

# Load system bash completion
source_if_exists "/etc/bash_completion"
# Load Homebrew bash completion, see https://docs.brew.sh/Shell-Completion
source_if_exists "/opt/homebrew/etc/profile.d/bash_completion.sh"

# Load local bash completion
source_if_exists "$HOME/.local/completion.d"

# FZF {{{

# Shell integration for ctrl-t & alt-c. Must come after bash-completion,
# which sets its own `complete -D` handler that would otherwise take over
# `**<tab>` for commands without their own completion
if command_exists fzf; then
  eval "$(fzf --bash)"
fi

# Note: --multi set by default here, so need to disable when inappropriate
export FZF_DEFAULT_OPTS_FILE="$HOME/.fzf-default-options"

# Debian's fdfind is linked as fd by script/update
if command_exists fd; then
  # Use `fd` when available for far better performance
  #
  # $FZF_DEFAULT_COMMAND is executed with `sh -c`, so need to be careful with
  # POSIX compliance
  export FZF_DEFAULT_COMMAND="fd --type file --hidden --color always"
  export FZF_ALT_C_COMMAND="fd --type directory --hidden --color always"
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

# Load aliases
source_if_exists "$HOME/.aliases"

# Load local overrides
source_if_exists "$HOME/.bashrc.local"

# Mark prompt start last (see OSC 133 section above)
if declare -F __osc133_mark_prompt >/dev/null; then
  PROMPT_COMMAND="$PROMPT_COMMAND; __osc133_mark_prompt"
fi
