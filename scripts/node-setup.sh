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

echo "$ARROW Installing node and yarn (requires sudo)"
installAptPackagesIfMissing nodejs yarn

if ! update-alternatives --get-selections | grep -q "^node"; then
  echo "$ARROW Updating alternatives to set symlinks for nodejs to node"
  sudo update-alternatives --install \
    /usr/bin/node node "$(command -v nodejs)" 10
fi
echo "$CMARK Node system alternatives set"

# Create directories for packages
NPM_PREFIX=$HOME/.local
NPM_CACHE_DIR=$HOME/.cache/npm
mkdir -p "$NPM_PREFIX/bin"
mkdir -p "$NPM_CACHE_DIR"

# Yarn is fast enough that we just install everything at once
echo "$ARROW Installing global node packages"
< "$HOME/dotfiles/scripts/node-packages" xargs yarn global add

# Make sure $PATH is up to date
source "$HOME/.profile"
# Setup latest node/npm locally
n stable

echo "$CMARK All node packages installed"
