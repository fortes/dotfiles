# For platform-specific conditions
OS=`uname`

# Remember stuff
HISTSIZE=1000
SAVEHIST=$HISTSIZE
HISTFILE=~/.history

# Load function-based completion system
autoload -U compinit && compinit

# Easier color output
autoload -U colors && colors

# Zsh Options {{{

# Change directory by typing its name like a command (useful with fzf)
setopt auto_cd

# Make cd push the old directory onto the stack
setopt auto_pushd

# Ignore duplicates in directory stack
setopt pushd_ignore_dups

# Compact match display
setopt LIST_PACKED

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

# user@host: in red in OSX, green otherwise
if [[ $OS == "Darwin" ]]; then
  PS1='%F{red}%n@%m%f:'
else
  PS1='%F{green}%n@%m%f:'
fi
# full directory name in yellow
PS1+='%F{yellow}%~%f '
# Number of suspended jobs, if >= 1
PS1+='%1(j. %F{cyan}[%j]%f.)'
# % if normal user, $ if root
PS1+='%# '
# Current time in 18:30 format
RPS1='%F{magenta}%T%f'

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

# }}}

# Environment / Configuration {{{

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
