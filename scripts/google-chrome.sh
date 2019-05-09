#!/bin/bash
set -ef -o pipefail

# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if ! isAptPackageInstalled google-chrome-unstable; then
  echo "$XMARK Chrome unstable not installed"
  echo "  $ARROW Adding Google Chrome signing key (requires sudo)"
  curl --silent https://dl.google.com/linux/linux_signing_key.pub \
    | sudo apt-key add -

  echo "  $ARROW Downloading Chrome Unstable Installer"
  curl --silent -O "http://dl.google.com/linux/direct/google-chrome-unstable_current_amd64.deb"
  echo "  $ARROW Installing Chrome unstable"
  sudo dpkg --install google-chrome-unstable_current_amd64.deb
  rm google-chrome-unstable_current_amd64.deb
fi

echo "$CMARK Chrome unstable installed"
