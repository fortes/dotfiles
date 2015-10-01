#!/bin/bash
set -ef -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

if ! which npm > /dev/null; then
  echo "$XMARK node/npm must be installed first"
  exit 1
fi

# Create storage directory for npm packages
if [ ! -d $HOME/npm ]; then
  echo "$ARROW Creating npm directory"
  mkdir -p $HOME/npm
fi

echo "$ARROW setting npm prefix to $HOME/npm"
npm config set prefix $HOME/npm
echo "  $INFO must 'source ~/.profile' / restart to take effect"
source ~/.profile

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
