# Better path
PS1="\t \u@\h:\w$ "
PS1="\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[1;33m\]\w\[\e[m\] \[\e[0;37m\]\A [\j]\$\[\e[m\] \[\e[0m\]"

# For default CoffeeLint settings
export COFFEELINT_CONFIG=~/.coffeelint.json

# Map ls to be colorful
if [[ $(uname) == "Linux" ]]; then
  alias ls='ls --color=auto -GpFh'
  alias la='ls -la --color=auto -GpFh'
else
  alias ls='ls -GpFh'
  alias la='ls -la -GpFh'
fi
# Nicer colors
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# JSON Viewing view python
alias json='python -mjson.tool'

# Colorized cat (nyan)
alias nyan='pygmentize -O style=friendly -f console256 -g'

# Tmux over screen
alias screen='tmux'

# MAC manipulators, via jashkenas
alias random_mac='sudo ifconfig en0 ether `openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//"`'
alias restore_mac='sudo ifconfig en0 ether b8:8d:12:0b:30:30'

# Enable options:
shopt -s autocd
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

# Load local file if present
if [ -f ~/.bashrc.local ]; then
  source ~/.bashrc.local
fi
