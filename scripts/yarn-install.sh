#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

YARN_SOURCES_FILE=/etc/apt/sources.list.d/yarn.list
if [ ! -f $YARN_SOURCES_FILE ]; then
  echo "$XMARK Yarn not in sources.list"
  echo "  $ARROW Adding yarn to in sources.list (requires sudo)"
  sudo apt-key adv --keyserver pgp.mit.edu --recv 9D41F3C3
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
    sudo tee "$YARN_SOURCES_FILE"
  sudo apt-get update -qq
fi
echo "$CMARK Yarn in sources.list"

echo "$ARROW Installing Yarn (requires sudo)"
installAptPackagesIfMissing yarn
