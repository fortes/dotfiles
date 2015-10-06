#!/bin/bash
set -euf
source $HOME/dotfiles/scripts/helpers.sh

# Ubuntu cmus is ancient
if [ "$OS" = 'Linux' ] && ! which cmus > /dev/null; then
  LATEST_URL="https://github.com/cmus/cmus/archive/v2.7.1.tar.gz"
  OPT_DIR=$HOME/opt
  INSTALL_DIR="$OPT_DIR/source/cmus"

  echo "$ARROW Installing build dependencies (requires sudo)"
  sudo apt-get install -qfuy libmad0-dev libao-dev libncursesw5-dev

  mkdir -p $INSTALL_DIR

  pushd $INSTALL_DIR > /dev/null
  echo "Downloading cmus 2.7.1 ..."
  wget -q $LATEST_URL -O cmus.tar.gz
  tar zxf cmus.tar.gz -C $INSTALL_DIR --strip-components=1
  rm cmus.tar.gz
  ./configure prefix=$OPT_DIR
  make install
  echo make install
  popd > /dev/null
fi

echo "$CMARK cmus installed"
