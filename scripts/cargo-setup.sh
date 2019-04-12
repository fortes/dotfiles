#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"
# Make sure to pick up path settings before install fully complete
source "$HOME/dotfiles/stowed-files/bash/.profile"

echo "$ARROW Installing/upgrading cargo packages"
for PACKAGE in $(cat $HOME/dotfiles/scripts/cargo-packages); do
  if ! cargo install --list | grep -q " $PACKAGE"; then
    echo "$ARROW Building $PACKAGE"
    cargo install -q "$PACKAGE"
  fi
  echo "$CMARK $PACKAGE installed"
done
echo "$CMARK All cargo packages installed"
