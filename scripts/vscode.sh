#!/bin/bash
set -ef -o pipefail

# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

VSCODE_SOURCES_LIST=/etc/apt/sources.list.d/vscode.list
if [ ! -f $VSCODE_SOURCES_LIST ]; then
  echo "$XMARK Microsoft not in sources.list"
  echo "  $ARROW Adding Microsoft to in sources.list (requires sudo)"
  curl https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  rm microsoft.gpg
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | \
    sudo tee "$VSCODE_SOURCES_LIST" > /dev/null
  sudo apt-get update -qq
fi
echo "$CMARK Yarn in sources.list"

echo "$ARROW Installing vscode (requires sudo)"
installAptPackagesIfMissing code
echo "$CMARK vscode installed"
