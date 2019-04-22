#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

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
