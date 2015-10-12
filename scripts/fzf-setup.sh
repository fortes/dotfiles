#/bin/bash
set -euf -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

FZF_SOURCE_DIR=$HOME/.local/source/fzf

if ! which fzf > /dev/null; then
  echo "$XMARK FZF not installed"

  if [ "$OS" = 'Darwin' ]; then
    echo "  $ARROW Installing FZF"
    brew reinstall --HEAD fzf
    echo "  $ARROW Running FZF install script"
    $(brew info fzf | grep /install)
  elif [ ! -d $FZF_SOURCE_DIR ]; then
    echo "  $ARROW Installing FZF"
    git clone --depth 1 https://github.com/junegunn/fzf.git $FZF_SOURCE_DIR
    echo "  $ARROW Running FZF install script"
    ($FZF_SOURCE_DIR/install)
  else
    echo "$XMARK FZF not installed but installation directory already present"
    exit 1
  fi
fi

echo "$CMARK FZF installed"
