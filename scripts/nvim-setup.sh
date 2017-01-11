#!/bin/bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v nvim > /dev/null; then
  echo "$XMARK Neovim not installed"

  if command -v apt-get > /dev/null; then
    # Debian can use the Ubuntu PPAs, but map to xenial (unstable)
    if [ "$DISTRO" = "Ubuntu" ]; then
      sudo add-apt-repository -y ppa:neovim-ppa/unstable > /dev/null
    else
      sudo add-apt-repository -y "deb http://ppa.launchpad.net/neovim-ppa/unstable/ubuntu xenial main" > /dev/null
    fi
    echo "  $ARROW Adding NeoVim PPA (requires sudo)"
    echo "  $ARROW Updating apt & installing neovim"
    sudo apt-get -q update
    sudo apt-get -qqfuy install neovim

    if command -v update-alternatives > /dev/null; then
      echo "    $ARROW Updating system editor alternatives to set symlinks"
      sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
      sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
      sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
      echo "  $CMARK System editor alternatives updated"
    fi
  else
    echo "$XMARK Platform not supported"
    exit 1
  fi
fi

echo "$CMARK Neovim installed"
NVIM_CONFIG_DIR=$HOME/.config/nvim

if [ ! -f "$NVIM_CONFIG_DIR/autoload/plug.vim" ]; then
  echo "  $XMARK vim-plug not installed"
  echo "    $ARROW Installing vim-plug"
  curl -fLo "$NVIM_CONFIG_DIR/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    2> /dev/null
  echo "  $CMARK vim-plug installed"
  echo "  $ARROW Installing plugins..."
  nvim +PlugInstall +qall
fi

echo "$CMARK NeoVim setup complete"
