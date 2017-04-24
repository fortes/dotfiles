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

# npm isn't available from the debian repository in stretch (wtf?), so we use
# yarn to temporarily install n, which we then use to install node lts, which
# comes with npm (and can officially run yarn). Note that this may break someday
# in the future, since yarn requires node v6+
if ! command -v npm > /dev/null; then
  pushd /tmp > /dev/null
  echo "$ARROW installing local node lts and npm"
  yarn add n
  N_PREFIX=$NPM_PREFIX /tmp/node_modules/.bin/n lts
  rm -rf /tmp/node_modules /tmp/package.json
  popd > /dev/null
fi

# Make sure we have latest path for node / npm before running yarn, which needs
# node v6+
export PATH="$NPM_PREFIX/bin:$PATH"

# Yarn is fast enough that we just install everything at once
echo "$ARROW Installing global node packages"
yarn global add $(xargs < "$HOME/dotfiles/scripts/node-packages")

echo "$CMARK All node packages installed"
