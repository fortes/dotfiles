#!/bin/bash
set -eo pipefail

DOTFILES_DIR=$HOME/dotfiles
OS=`uname`

if [ $OS == 'Darwin' ]; then
  if [[ -z $(brew tap | grep -i neovim) ]]; then
    echo 'Adding NeoVim tap to Homebrew'
    brew tap neovim/homebrew-neovim
  fi
  if which neovim &> /dev/null; then
    echo 'Installing latest NeoVim from HEAD'
    #brew install --HEAD neovim
  else
    read -p 'NeoVim already installed. Update from HEAD [yn]? ' -n 1 -r
    echo ''
    if [[ $REPLY =~ [Yy]$ ]]; then
      echo 'Updating to latest NeoVim'
      #brew update
      #brew reinstall --HEAD neovim
    else
      echo 'Skipping NeoVim update'
    fi
  fi
elif [ $OS == 'Linux' ]; then
  echo 'TOOD: Linux installation'
  exit 1
fi

echo '✓ NeoVim installed!'

if [ ! -f $HOME/.nvim/autoload/plug.vim ]; then
  echo 'Installing vim-plug for Neovim'
  curl -fLo ~/.nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if ! diff $HOME/.nvimrc $HOME/dotfiles/symlinks/nvimrc &> /dev/null; then
  if [ -f $HOME/.nvimrc ]; then
    echo 'Moving old .nvimrc to .nvimrc.old'
    mv $HOME/.nvimrc $HOME/.nvimrc.old
  fi
  echo 'Linking .nvimrc'
  ln -s $HOME/dotfiles/symlinks/nvimrc $HOME/.nvimrc
fi

echo 'Installing plugins'
nvim +PlugInstall +qall
echo '✓ NeoVim setup complete'
