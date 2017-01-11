#!/bin/bash
set -euf
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

# Ubuntu cmus is ancient
if command -v apt-get > /dev/null && ! command -v cmus > /dev/null; then
  LOCAL_DIR=$HOME/.local

  echo "$ARROW Installing build dependencies (requires sudo)"
  sudo apt-get -qqfuy install libmad0-dev libao-dev libncursesw5-dev

  SOURCE_DIR="$LOCAL_DIR/source/cmus"
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "$ARROW Cloning repository"
    git clone https://github.com/cmus/cmus.git "$SOURCE_DIR"
    pushd "$SOURCE_DIR" > /dev/null
  else
    pushd "$SOURCE_DIR" > /dev/null
    echo "$ARROW Pulling repository for latest"
    git pull
  fi
  ./configure prefix="$LOCAL_DIR"
  make install
  echo make install
  popd > /dev/null
fi

echo "$CMARK cmus installed"
