#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v nodejs > /dev/null; then
  if command -v apt-get > /dev/null; then
    echo "$ARROW Adding $DISTRO nodesource PPA (requires sudo)"
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | \
      sudo apt-key add -
    sudo add-apt-repository -y "deb https://deb.nodesource.com/node_6.x ${VERSION,,} main"

    sudo apt-get update
    echo "$ARROW Installing node (requires sudo)"
    installAptPackagesIfMissing nodejs

    if command -v update-alternatives > /dev/null; then
      if ! command -v node > /dev/null; then
        echo "$ARROW Updating alternatives to set symlinks for nodejs to node"
        sudo update-alternatives --install /usr/bin/node node "$(command -v nodejs)" 10
        echo "$CMARK System alternatives updated"
      fi
    fi
  else
    echo "$XMARK Unsupported platform for node install"
    exit 1
  fi
fi

if ! command -v npm > /dev/null; then
  echo "$XMARK node/npm must be installed first"
  exit 1
fi

# Make sure we have correct value for $XDG_CACHE_HOME
source ~/.profile
NPM_PREFIX=$HOME/.local
NPM_CACHE_DIR=$XDG_CACHE_HOME/npm

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
