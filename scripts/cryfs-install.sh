#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v apt-get > /dev/null; then
  echo "$XMARK Setup only supported on Ubuntu systems for now"
  exit 1
fi

APT_LIST_FILEPATH=/etc/apt/sources.list.d/cryfs.list
if [ ! -f "$APT_LIST_FILEPATH" ]; then
  echo "$ARROW Adding cryfs apt key (requires sudo)"

  # Add apt key
  wget -q -O - https://www.cryfs.org/apt.key | sudo apt-key add -

  echo "$ARROW Adding cryfs repository to sources.list (requires sudo)"
  echo "deb http://apt.cryfs.org/debian jessie main" | \
    sudo tee "$APT_LIST_FILEPATH"

  echo "$ARROW Updating sources (requires sudo)"
  sudo apt-get -q update
fi

if ! command -v cryfs > /dev/null; then
  echo "$ARROW Installing (requires sudo)"
  sudo apt-get -qqfuy install cryfs
fi

echo "$CMARK cryfs installed"
