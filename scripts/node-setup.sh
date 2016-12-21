#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

YARN_SOURCES_FILE=/etc/apt/sources.list.d/yarn.list
if [ ! -f $YARN_SOURCES_FILE ]; then
  echo "$XMARK Yarn not in sources.list"
  echo "  $ARROW Adding yarn to in sources.list (requires sudo)"
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
    sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
    sudo tee "$YARN_SOURCES_FILE" > /dev/null
  sudo apt-get update -qq
fi
echo "$CMARK Yarn in sources.list"

echo "$ARROW Installing node, npm, and yarn (requires sudo)"
installAptPackagesIfMissing nodejs npm yarn

if ! update-alternatives --get-selections | grep -v -q "^node"; then
  echo "$ARROW Updating alternatives to set symlinks for nodejs to node"
  sudo update-alternatives --install \
    /usr/bin/node node "$(command -v nodejs)" 10
fi
echo "$CMARK Node system alternatives set"

# Create directories for packages
NPM_PREFIX=$HOME/.local
NPM_CACHE_DIR=$HOME/.cache/npm
npm config set prefix "$NPM_PREFIX"
npm config set cache "$NPM_CACHE_DIR"
mkdir -p "$NPM_PREFIX/bin"
mkdir -p "$NPM_CACHE_DIR"

# Yarn is fast enough that we just install everything at once
echo "  $ARROW Installing global node packages"
yarn global add $(xargs < "$HOME/dotfiles/scripts/node-packages")

# Use latest node via n instead of relying on old packages, this also provides
# npm
if which node | grep -iq /usr/bin; then
  echo "  $ARROW Using n to get latest lts"
  n lts
fi

echo "$CMARK All node packages installed"
