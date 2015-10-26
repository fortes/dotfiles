#!/bin/bash
set -euf -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

if ! which nvim > /dev/null; then
  echo "$XMARK Neovim not installed"

  if [ "$OS" = 'Darwin' ]; then
    echo "  $ARROW Adding NeoVim tap to Homebrew"
    brew tap neovim/homebrew-neovim > /dev/null 2> /dev/null
    echo "  $ARROW Installing latest NeoVim from HEAD"
    brew install --HEAD neovim 2> /dev/null
  elif which apt-get > /dev/null; then
    echo "  $ARROW Adding NeoVim PPA (requires sudo)"
    sudo add-apt-repository ppa:neovim-ppa/unstable
    echo "  $ARROW Updating apt & installing neovim"
    sudo apt-get -q update
    sudo apt-get -qfuy install neovim

    if which update-alternatives > /dev/null; then
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
else
  if [ "$OS" == "Darwin" ]; then
    read -p "NeoVim already installed. Update from HEAD [yn]? " -n 1 -r
    echo ""
    if [[ $REPLY =~ [Yy]$ ]]; then
      echo "  $ARROW Updating to latest NeoVim"
      brew update
      brew reinstall --HEAD neovim
    else
      echo "Skipping NeoVim update"
    fi
  fi
fi

echo "$CMARK Neovim installed"
NVIM_CONFIG_DIR=$XDG_CONFIG_HOME/nvim

if [ ! -f $NVIM_CONFIG_DIR/autoload/plug.vim ]; then
  echo "  $XMARK vim-plug not installed"
  echo "    $ARROW Installing vim-plug"
  curl -fLo $NVIM_CONFIG_DIR/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    2> /dev/null
  echo "  $CMARK vim-plug installed"
  echo "  $ARROW Installing plugins..."
  nvim +PlugInstall +qall
fi

echo "$CMARK NeoVim setup complete"
