#!/usr/bin/env bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

# Official
# curl -s 'https://raw.githubusercontent.com/zerotier/download.zerotier.com/master/htdocs/contact%40zerotier.com.gpg' | gpg --import && \
# if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi

ZEROTIER_SOURCES_LIST=/etc/apt/sources.list.d/zerotier.list
if [ ! -f $ZEROTIER_SOURCES_LIST ]; then
  ZEROTIER_KEY_URL='https://raw.githubusercontent.com/zerotier/download.zerotier.com/master/htdocs/contact%40zerotier.com.gpg'
  echo "$XMARK Zerotier not in sources.list"

  echo "  $ARROW Adding zerotier gpg key"
  curl -sS "$ZEROTIER_KEY_URL" | sudo apt-key add -

  echo "  $ARROW Adding zerotier to in sources.list (requires sudo)"
  echo "deb http://download.zerotier.com/debian/buster buster main" | \
    sudo tee $ZEROTIER_SOURCES_LIST

  echo "$CMARK Zerotier in sources.list, updating sources"
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq

  echo "$ARROW Getting keyring for Multimedia"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install deb-multimedia-keyring -oAcquire::AllowInsecureRepositories=true
fi
echo "$CMARK Zerotier in sources.list"

echo "$ARROW Installing Zerotier (requires sudo)"
installAptPackagesIfMissing zerotier-one
