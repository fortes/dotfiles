#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

NODE_SOURCES_FILE=/etc/apt/sources.list.d/node.list
if [ ! -f "$NODE_SOURCES_FILE" ]; then
  echo "$XMARK Node not in sources.list"
  echo "  $ARROW Adding node to in sources.list (requires sudo)"
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | \
    sudo apt-key add -

  # TODO: Switch over to stretch, once ready
  echo "deb https://deb.nodesource.com/node_6.x jessie main" | \
    sudo tee "$NODE_SOURCES_FILE"
  sudo apt-get update -qq
fi

echo "$ARROW Installing node (requires sudo)"
installAptPackagesIfMissing nodejs

if ! update-alternatives --get-selections | grep -v -q "^node"; then
  echo "$ARROW Updating alternatives to set symlinks for nodejs to node"
  sudo update-alternatives --install /usr/bin/node node \
    "$(command -v nodejs)" 10
fi
echo "$CMARK Node system alternatives set"

if ! command -v npm > /dev/null; then
  echo "$XMARK npm not installed"
  installAptPackagesIfMissing npm
  exit 1
fi
echo "$CMARK npm installed"

NPM_PREFIX=$HOME/.local
NPM_CACHE_DIR=$HOME/.cache/npm

# Create storage directory for npm packages
if [ ! -d "$NPM_PREFIX" ]; then
  echo "$ARROW Creating npm directory"
  mkdir -p "$NPM_PREFIX"
fi

if ! npm get prefix | grep -qx "$NPM_PREFIX"; then
  echo "$ARROW setting npm prefix to $NPM_PREFIX"
  npm config set prefix "$NPM_PREFIX"
fi
unset NPM_PREFIX

if ! npm get cache | grep -qx "$NPM_CACHE_DIR"; then
  echo "$ARROW setting npm cache to $NPM_CACHE_DIR"
  npm config set cache "$NPM_CACHE_DIR"
fi
unset NPM_CACHE_DIR

# Cache output since npm list can be slow
NPM_PACKAGES=$(npm list -g --depth 0)
PACKAGES=''
for p in $(xargs < "$HOME/dotfiles/scripts/npm-packages"); do
  if ! echo "$NPM_PACKAGES" | grep -q "$p@"; then
    echo "$XMARK npm package $p not installed"
    PACKAGES="$PACKAGES $p"
  else
    echo "$CMARK $p installed"
  fi
done

if [ "$PACKAGES" != "" ]; then
  echo "  $ARROW Installing global npm packages$PACKAGES"
  npm install -g -q $PACKAGES
  echo "$CMARK $PACKAGES installed"
fi

echo "$CMARK All npm packages installed"
