OS=`uname`

# If not running interactively, do nothing
case $- in
  *i*) ;;
    *) return;;
esac

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

# Everyone's favorite editor
export VISUAL=vim
export EDITOR=vim

# Confirm file overwrite
alias mv='mv -i'

# Nicer colors
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# For default CoffeeLint settings
export COFFEELINT_CONFIG=~/.coffeelint.json

# Beets configuration files
export BEETSDIR=$HOME/.beets/

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
alias nyan='pygmentize -O style=default -f console256 -g'

# Debugging CoffeeScript
alias coffeedebug='coffee --nodejs --debug-brk'

# Have eslint pick up default config
alias eslint='eslint -c ~/.eslintrc'

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

# Don't put duplicate lines into history
HISTCONTROL=ignoredup
# Set history length
HISTSIZE=1000
HISTFILESIZE=2000

# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
if [ "${BASH_VERSION%.*}" \> "4.2" ]; then
  # Not supported in OS X version of bash
  shopt -s autocd
  shopt -s globstar
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# virtualenv should use Distribute instead of legacy setuptools
export VIRTUALENV_DISTRIBUTE=true
# Centralized location for new virtual environments
export PIP_VIRTUALENV_BASE=$HOME/virtualenvs
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

# Update commands
DIST_UPDATE_COMMANDS=()
DIST_UPDATE_COMMANDS+=('npm update -g')
DIST_UPDATE_COMMANDS+=('vim +NeoBundleUpdate +qall')
DIST_UPDATE_COMMANDS+=("pip install --upgrade $(cat $HOME/dotfiles/scripts/python-packages | tr '\n', ' ')")

# Load OS-specific files
if [ $OS == "Darwin" ]; then
  if [ -f ~/.bashrc.osx ]; then
    source ~/.bashrc.osx
  fi
elif [ $OS == "Linux" ]; then
  if [ -f ~/.bashrc.linux ]; then
    source ~/.bashrc.linux
  fi
fi

# Helper command for updating all package managers
function dist_update() {
  for cmd in "${DIST_UPDATE_COMMANDS[@]}"; do
    $cmd
  done
}

export -f dist_update

# Activate default virtual env, if not already in an env
if [ -d $PIP_VIRTUALENV_BASE/default ]; then
  PROMPT=$PS1
  source $PIP_VIRTUALENV_BASE/default/bin/activate
  # Reset prompt to default
  PS1=$PROMPT
fi

# Load local file if present
if [ -f ~/.bashrc.local ]; then
  source ~/.bashrc.local
fi
