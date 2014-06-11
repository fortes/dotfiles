OS=`uname`

# Map ls to be colorful
if [ $OS == "Darwin" ]; then
  alias ls='ls -GpFh'
  alias la='ls -la -GpFh'
  # Red username on mac
  PS1="\[\e[0;31m\]\u@\h\[\e[m\]:\[\e[1;33m\]\w\[\e[m\] \[\e[0;37m\]\A [\j]\$\[\e[m\] \[\e[0m\]"
else
  alias ls='ls --color=auto -GpFh'
  alias la='ls -la --color=auto -GpFh'
  # Green username on linux
  PS1="\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[1;33m\]\w\[\e[m\] \[\e[0;37m\]\A [\j]\$\[\e[m\] \[\e[0m\]"
fi

# Nicer colors
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# For default CoffeeLint settings
export COFFEELINT_CONFIG=~/.coffeelint.json

# Easy timezones
alias lisbon='TZ="Europe/Lisbon" date'
alias nyc='TZ="America/New_York" date'
alias sf='TZ="America/Los_Angeles" date'
alias rio='TZ="America/Sao_Paulo" date'
alias bj='TZ="Asia/Shanghai" date'
alias utc='TZ="UTC" date'

# Easy CD
alias ..="cd .."
alias ...="cd .. && cd .."

# JSON Viewing view python
alias json='python -mjson.tool'

# Colorized cat (nyan)
alias nyan='pygmentize -O style=friendly -f console256 -g'

# Debugging CoffeeScript
alias coffeedebug='coffee --nodejs --debug-brk'

# Tmux over screen
alias screen='tmux'

# Tyops and shortcuts
alias l='ls'
alias g='git'
alias v='vim'
alias pythong='python'

# Get readable list of network IPs
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
# Flush DNS cache
alias flush="dscacheutil -flushcache"

# Enable options:
# shopt -s autocd # Not supported in OS X version of bash
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# virtualenv should use Distribute instead of legacy setuptools
export VIRTUALENV_DISTRIBUTE=true
# Centralized location for new virtual environments
export PIP_VIRTUALENV_BASE=$HOME/virtualenvs
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

# Load OS-specific files
if [ $OS == "Darwin" ]; then
  if [ -f ~/.bashrc.osx ]; then
    source ~/.bashrc.osx
  fi
fi

# Activate default virtual env, if not already in an env
if [ -z $VIRTUAL_ENV ]; then
  if [ -d $PIP_VIRTUALENV_BASE/default ]; then
    PROMPT=$PS1
    source $PIP_VIRTUALENV_BASE/default/bin/activate
    # Reset prompt to default
    PS1=$PROMPT
  fi
fi

# Load local file if present
if [ -f ~/.bashrc.local ]; then
  source ~/.bashrc.local
fi
