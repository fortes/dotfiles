#!/bin/bash
set -ef -o pipefail
# shellcheck source=./helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if [[ "$IS_CROUTON" == 1 ]]; then
  echo "$XMARK Crouton does not support Docker"
  exit 1
fi

echo "$ARROW Installing Docker and dependencies (requires sudo)"
installAptPackagesIfMissing docker.io

if [ ! -f "/etc/sudoers.d/$USER-docker" ]; then
  echo "$ARROW Allowing $USER to run docker without sudo prompt (requires sudo)"
  echo "$(whoami)  ALL=(ALL) NOPASSWD: /usr/bin/docker" |
    sudo tee &> /dev/null "/etc/sudoers.d/$USER-docker"
fi
echo "$CMARK Sudo-less docker setup"

echo "$CMARK Docker installed and setup"
