#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

# Instructions from https://backports.debian.org/Instructions/
BACKPORTS_FILE=/etc/apt/sources.list.d/jessie-backports.list
if [ ! -f $BACKPORTS_FILE ]; then
  echo "$XMARK Backports not in sources.list"
  echo "  $ARROW Adding backports to in sources.list (requires sudo)"
  echo "deb http://ftp.debian.org/debian jessie-backports main" | \
    sudo tee $BACKPORTS_FILE
  echo "$CMARK Backports in sources.list, updating sources"
  sudo apt-get update -qq
fi

echo "$CMARK Backports setup. Use 'apt-get -t $VERSION-backports install'"
