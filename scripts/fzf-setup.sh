#/bin/bash
set -euf -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

if ! which fzf > /dev/null; then
  echo "$XMARK FZF not installed"

  if [ "$OS" = 'Darwin' ]; then
    echo "  $ARROW Installing FZF"
    brew reinstall --HEAD fzf
    echo "  $ARROW Running FZF install script"
    $(brew info fzf | grep /install)
  elif [ ! -d $HOME/.fzf ]; then
    echo "  $ARROW Installing FZF"
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
    echo "  $ARROW Running FZF install script"
    ($HOME/.fzf/install)
  else
    echo "$XMARK FZF not installed but installation directory already present"
    exit 1
  fi
fi

echo "$CMARK FZF installed"
