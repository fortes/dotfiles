# For platform-specific conditions
OS=`uname`

# Remember stuff
HISTSIZE=1000
SAVEHIST=$HISTSIZE
HISTFILE=~/.history

# Easier color output
autoload -U colors && colors

# Load function-based completion system
autoload -U compinit && compinit

# For Git info in prompt
autoload -Uz vcs_info

# Zsh Options {{{

# Change directory by typing its name like a command (useful with fzf)
setopt auto_cd

# Make cd push the old directory onto the stack
setopt auto_pushd

# Ignore duplicates in directory stack
setopt pushd_ignore_dups

# Compact match display
setopt list_packed

# More powerful pattern matching
setopt extended_glob

# Enable auto-correction
setopt correctall

# Ignore duplicates in history
setopt hist_ignore_all_dups

# Prevent command from going into history by prepending a space
setopt hist_ignore_space

# Don't wait until exiting the shell to write to history
setopt inc_append_history

# Share history with all other shells
setopt share_history

# Enable prompt expansion for nicer prompts
setopt prompt_subst

# /Options }}}

# VirtualEnv {{{
# virtualenv should use Distribute instead of legacy setuptools
export VIRTUALENV_DISTRIBUTE=true
# Centralized location for new virtual environments
export PIP_VIRTUALENV_BASE=$HOME/virtualenvs
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

# Activate default virtual env, if not already in an env
if [ -z $VIRTUAL_ENV ] && [ -d $PIP_VIRTUALENV_BASE/default ]; then
  # This will modify the prompt, so do it before setting the prompt
  source $PIP_VIRTUALENV_BASE/default/bin/activate
fi
# }}}

# Prompt {{{

# Only do VCS detection for Git
zstyle ':vcs_info:*' enable git
# Add yellow dot next to repo when there are staged changes
zstyle ':vcs_info:*' stagedstr ' %F{yellow}●%f'
# Add red dot next to repo when there are unstaged changes
zstyle ':vcs_info:*' unstagedstr ' %F{red}●%f'
zstyle ':vcs_info:*' check-for-changes true
# Used during an action, like rebase
zstyle ':vcs_info:*' actionformats '(%F{yellow}%b%f|%F{magenta}%a%f)'
# Normal prompt, just shows repo name in green
zstyle ':vcs_info:*' formats '(%F{green}%b%c%u%f)'
precmd () {
  vcs_info
}

# user@host: in red in OSX, green otherwise
if [[ $OS == "Darwin" ]]; then
  PS1='%F{red}%n@%m%f:'
else
  PS1='%F{green}%n@%m%f:'
fi
# Current Time in 18:30 format
PS1='%F{magenta}[%T]%f '$PS1
# full directory name in yellow
PS1+='%F{yellow}%~%f '
# Include VCS info
PS1+='${vcs_info_msg_0_}'
# Number of suspended jobs, if >= 1
PS1+='%1(j. %F{cyan}[%j]%f.)'
# % if normal user, $ if root
PS1+='%# '
# Right side: Current time in 18:30 format
#RPS1='%F{magenta}%T%f'
# Spelling correction prompt
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# /Prompt }}}

# Shortcuts and Utilities {{{

# Easy timezones for places I care about
alias lisbon='TZ="Europe/Lisbon" date'
alias nyc='TZ="America/New_York" date'
alias sf='TZ="America/Los_Angeles" date'
alias rio='TZ="America/Sao_Paulo" date'
alias utc='TZ="UTC" date'

# Get readable list of network IPs
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias mygeo="curl -w \"\\n\" http://api.hackertarget.com/geoip/?q=`dig +short myip.opendns.com @resolver1.opendns.com`"

# Flush DNS cache
alias dnsflush="dscacheutil -flushcache"

# JSON Viewing view python
alias json='python -mjson.tool'

# Colorized cat (nyan)
alias nyan='pygmentize -O style=default -f console256 -g'

# Confirm file overwrite
alias mv='mv -i'

# CD into root of git project
alias pcd="cd \$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"

# Map ls to be colorful
if [[ $OS == "Darwin" ]]; then
  alias ls='ls -GpFh'
else
  alias ls='ls --color=auto -GpFh'
fi

# }}}

# Environment / Configuration {{{

# Everyone's favorite editor
export VISUAL=vim
export EDITOR=vim

# Nicer colors. BSD uses $LSCOLORS, linux uses $LS_COLORS
export LSCOLORS=gxfxbxbxCxegedabagGxGx
export LS_COLORS='di=36;40:ln=35;40:so=31;40:pi=31;40:ex=1;32;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=36;01:ow=36;01:'

# Use same ls colors for completion, zsh uses linux-style colors
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# For default CoffeeLint settings
if [ -f ~/.coffeelint.json ]; then
  export COFFEELINT_CONFIG=~/.coffeelint.json
fi

# Beets configuration files
export BEETSDIR=$HOME/.beets/

# Have eslint pick up default config
if [ -f ~/.eslintrc ]; then
  alias eslint='eslint -c ~/.eslintrc'
fi

# }}}

# Add fzf support, if present
if [ -f ~/.fzf.zsh ]; then
  # Honor .gitignore by default
  export FZF_DEFAULT_COMMAND='ag -l -g ""'
  source ~/.fzf.zsh
fi

# Load OS-specific files
if [[ $OS == "Darwin" ]]; then
  if [ -f ~/.zshrc.osx ]; then
    source ~/.zshrc.osx
  fi
elif [[ $OS == "Linux" ]]; then
  if [ -f ~/.zshrc.linux ]; then
    source ~/.zshrc.linux
  fi
fi

# Load local file if present
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
