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

# Options {{{

# Change directory by typing its name like a command (useful with fzf)
setopt auto_cd

# More powerful pattern matching
setopt extended_glob

# Enable auto-correction
setopt correctall

# Ignore duplicates in history
setopt hist_ignore_all_dups

# Prevent command from going into history by prepending a space
setopt hist_ignore_space

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

# user@host: in red
PS1='%F{red}%n@%m%f:'
# full directory name in yellow
PS1+='%F{yellow}%~%f '
# Number of suspended jobs, if >= 1
PS1+='%1(j. %F{cyan}[%j]%f.)'
# % if normal user, $ if root
PS1+='%# '
# Current time in 18:30 format
RPS1='%F{magenta}%T%f'

# /Prompt }}}

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
