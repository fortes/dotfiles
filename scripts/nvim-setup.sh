#!/bin/bash
set -eo pipefail

DOTFILES_DIR=$HOME/dotfiles

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

nvim +PlugInstall +qall
echo 'NeoVim setup complete'
