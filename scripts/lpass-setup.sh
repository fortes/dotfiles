#!/bin/bash
set -euf
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v apt-get &> /dev/null; then
  echo "$XMARK Non-debian not supported"
  exit 1
fi

if ! command -v lpass > /dev/null; then
  echo "$ARROW Installing build dependencies (requires sudo)"
  installAptPackagesIfMissing openssl libcurl3 libxml2 libssl-dev libxml2-dev \
    libcurl4-openssl-dev pinentry-curses

  LOCAL_DIR=$HOME/.local

  SOURCE_DIR="$LOCAL_DIR/source/lastpass-cli"
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "$ARROW Cloning repository"
    git clone git@github.com:lastpass/lastpass-cli.git "$SOURCE_DIR"
    pushd "$SOURCE_DIR" > /dev/null
  else
    pushd "$SOURCE_DIR" > /dev/null
    echo "$ARROW Pulling repository for latest"
    git pull
  fi

  make
  # Install everything locally so we don't need sudo
  COMPDIR="$LOCAL_DIR/completions.d" PREFIX="$LOCAL_DIR" BINDIR="$LOCAL_DIR/bin" \
    make install
  popd > /dev/null
fi

echo "$CMARK lpass installed"
