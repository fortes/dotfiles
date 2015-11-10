#!/bin/bash
set -ef -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

if ! which nodejs > /dev/null; then
  if which apt-get > /dev/null; then
    DISTRO=`lsb_release -s -c`
    echo "$ARROW Adding $DISTRO nodesource PPA (requires sudo)"
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | \
      sudo apt-key add -
    sudo add-apt-repository "deb https://deb.nodesource.com/node_5.x ${DISTRO} main"
    unset DISTRO

    sudo apt-get update
    echo "$ARROW Installing node (requires sudo)"
    installAptPackageIfMissing nodejs

    if which update-alternatives > /dev/null; then
      if ! which node > /dev/null; then
        echo "$ARROW Updating alternatives to set symlinks for nodejs to node"
        sudo update-alternatives --install /usr/bin/node node $(which nodejs) 10
        echo "$CMARK System alternatives updated"
      fi
    fi
  else
    echo "$XMARK Unsupported platform for node install"
    exit 1
  fi
fi

if ! which npm > /dev/null; then
  echo "$XMARK node/npm must be installed first"
  exit 1
fi

# Make sure we have correct value for $XDG_CACHE_HOME
source ~/.profile
NPM_PREFIX=$HOME/.local
NPM_CACHE_DIR=$XDG_CACHE_HOME/npm

# Create storage directory for npm packages
if [ ! -d $NPM_PREFIX ]; then
  echo "$ARROW Creating npm directory"
  mkdir -p $NPM_PREFIX
fi

if ! npm get prefix | grep -qx $NPM_PREFIX; then
  echo "$ARROW setting npm prefix to $NPM_PREFIX"
  npm config set prefix $NPM_PREFIX
fi
unset NPM_PREFIX

if ! npm get cache | grep -qx $NPM_CACHE_DIR; then
  echo "$ARROW setting npm cache to $NPM_CACHE_DIR"
  npm config set cache $NPM_CACHE_DIR
fi
unset NPM_CACHE_DIR

# Cache output since npm list can be slow
NPM_PACKAGES=$(npm list -g --depth 0)
for p in $(cat $HOME/dotfiles/scripts/npm-packages); do
  if ! echo "$NPM_PACKAGES" | grep -q "$p@"; then
    echo "$XMARK npm package $p not installed"
    echo "  $ARROW Installing global npm package $p"
    npm install -g -q $p
  fi
  echo "$CMARK $p installed"
done
echo "$CMARK All npm packages installed"
