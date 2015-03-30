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

# Setup a decent prompt
# user@host: in red
PS1='%F{red}%n@%m%f:'
# directory name in yellow
PS1+='%F{yellow}%.%f '
# Current time in 18:30 format
PS1+='%T'
# Number of suspended jobs, if >= 1
PS1+='%1(j. %F{cyan}[%j]%f.)'
# % if normal user, $ if root
PS1+='%# '
# Full directory name, in magenta
RPS1='%F{magenta}%~%f'

# Add fzf support, if present
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi
