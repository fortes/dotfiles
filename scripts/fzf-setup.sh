#!/bin/bash
set -euf -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

FZF_SOURCE_DIR=$HOME/.local/source/fzf

if ! command -v fzf > /dev/null; then
  echo "$XMARK FZF not installed"

  if [ "$OS" = 'Darwin' ]; then
    echo "  $ARROW Installing FZF"
    brew reinstall --HEAD fzf
  elif [ ! -d "$FZF_SOURCE_DIR" ]; then
    echo "  $ARROW Installing FZF"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_SOURCE_DIR"
  else
    echo "$XMARK FZF not installed but installation directory already present"
    exit 1
  fi
fi

echo "$CMARK FZF installed"

if [ "$OS" = 'Darwin' ]; then
  echo "  $ARROW Running FZF install script"
  $(brew info fzf | grep /install) --no-completion --key-bindings \
    --no-update-rc > /dev/null
elif [ -d "$FZF_SOURCE_DIR" ]; then
  echo "  $ARROW Running FZF install script"
  "$FZF_SOURCE_DIR/install" --no-completion --key-bindings --no-update-rc \
    > /dev/null
fi

echo "$CMARK FZF setup"
