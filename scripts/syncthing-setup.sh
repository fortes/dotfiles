#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v apt-get > /dev/null; then
  echo "$XMARK Setup only supported on Ubuntu systems for now"
  exit 1
fi

APT_LIST_FILEPATH=/etc/apt/sources.list.d/syncthing.list
if [ ! -f "$APT_LIST_FILEPATH" ]; then
  echo "$ARROW Adding syncthing apt key (requires sudo)"

  # Add apt key
  wget -q -O - https://syncthing.net/release-key.txt | \
    sudo apt-key add -

  echo "$ARROW Adding syncthing repository to sources.list (requires sudo)"
  echo "deb https://apt.syncthing.net/ syncthing release" | \
    sudo tee "$APT_LIST_FILEPATH"

  echo "$ARROW Updating sources (requires sudo)"
  sudo apt-get -q update
fi

if ! command -v syncthing > /dev/null; then
  echo "$ARROW Installing (requires sudo)"
  sudo apt-get -qqfuy install syncthing
fi

echo "$CMARK syncthing installed"
