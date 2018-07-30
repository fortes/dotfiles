#!/bin/bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

# Debian version currently super old, use this one instead
NVIM_APPIMAGE_PATH="$HOME/.local/bin/nvim"
if [ ! -f "$NVIM_APPIMAGE_PATH" ]; then
  echo "$XMARK nvim not installed"
  echo "$ARROW Downloading nvim appimage"
  wget -nv -O "$NVIM_APPIMAGE_PATH" \
    "https://github.com/neovim/neovim/releases/download/v0.3.1/nvim.appimage"
  chmod u+x "$NVIM_APPIMAGE_PATH"
  sudo update-alternatives \
    --install /usr/bin/editor editor $NVIM_APPIMAGE_PATH 60
fi
echo "$CMARK nvim installed"

NVIM_CONFIG_DIR="$HOME/.config/nvim"

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
