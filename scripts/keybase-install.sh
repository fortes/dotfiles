#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v keybase > /dev/null; then
  echo "$XMARK Keybase not installed"
  installAptPackagesIfMissing libappindicator1
  pushd /tmp > /dev/null
  curl -O "https://prerelease.keybase.io/keybase_amd64.deb"
  echo "$ARROW Installing .deb (requires sudo)"
  sudo dpkg -i keybase_amd64.deb
  rm -rf keybase_amd64.deb
  popd > /dev/null
  echo "$ARROW Doing keybase setup via \`run_keybase\`"
fi
echo "$CMARK Keybase installed"
