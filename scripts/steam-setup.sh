#!/bin/bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if ! dpkg --print-foreign-architectures | grep -q i386; then
  echo "$XMARK i386 architecture not present"
  echo "$ARROW Adding 32 bit (requires sudo)"
  sudo dpkg --add-architecture i386
  sudo apt-get -qq update
fi
echo "$CMARK i386 architecture present"

# Need to manually accept license
sudo apt-get install steam
