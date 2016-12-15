#!/bin/bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if update-alternatives --get-selections | grep "^editor" | grep -v -q nvim; then
  echo "$ARROW Updating system editor alternatives to set symlinks"
  NVIM_PATH=$(which nvim)
  sudo update-alternatives --install /usr/bin/vi vi "$NVIM_PATH" 60
  sudo update-alternatives --install /usr/bin/vim vim "$NVIM_PATH" 60
  sudo update-alternatives --install /usr/bin/editor editor "$NVIM_PATH" 60
  echo "$CMARK System editor alternatives updated"
fi

echo "$CMARK Neovim set as default editor"
NVIM_CONFIG_DIR=$HOME/.config/nvim

if [ ! -f "$NVIM_CONFIG_DIR/autoload/plug.vim" ]; then
  echo "$XMARK vim-plug not installed"
  echo "$ARROW Installing vim-plug"
  curl -fLo "$NVIM_CONFIG_DIR/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    2> /dev/null
  echo "$CMARK vim-plug installed"
  echo "$ARROW Installing plugins..."
  nvim +PlugInstall +qall
fi

echo "$CMARK NeoVim setup complete"
