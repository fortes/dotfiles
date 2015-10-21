#!/bin/bash
set -ef -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

if [ "$OS" == "Linux" ]; then
  if which nodejs > /dev/null && ! which node > /dev/null; then
    echo "$ARROW Updating alternatives to set symlinks for nodejs to node"
    sudo update-alternatives --install /usr/bin/node node $(which nodejs) 10
  fi
fi

if ! which npm > /dev/null; then
  echo "$XMARK node/npm must be installed first"
  exit 1
fi

NPM_PREFIX=$HOME/.local

# Create storage directory for npm packages
if [ ! -d $NPM_PREFIX ]; then
  echo "$ARROW Creating npm directory"
  mkdir -p $NPM_PREFIX
fi

if ! npm get prefix | grep -qx $NPM_PREFIX; then
  echo "$ARROW setting npm prefix to $NPM_PREFIX"
  npm config set prefix $NPM_PREFIX
  echo "  $INFO must 'source ~/.profile' or restart to take effect"
  source $HOME/.profile
fi

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
