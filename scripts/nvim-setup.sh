#!/bin/bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if ! update-alternatives --get-selections | grep editor | grep -q nvim; then
  sudo update-alternatives \
    --install /usr/bin/editor editor "$(command -v nvim)" 60
fi
echo "$CMARK nvim installed"

NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim"

if [ ! -f "$NVIM_CONFIG_DIR/autoload/plug.vim" ]; then
  echo "$XMARK vim-plug not installed"
  echo "$ARROW Installing vim-plug"
  curl -fLo "$NVIM_CONFIG_DIR/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    2> /dev/null
  echo "$CMARK vim-plug installed"
  echo "$ARROW Installing plugins..."
  nvim +PlugInstall +UpdateRemotePlugins +qall
fi

echo "$CMARK NeoVim setup complete"
