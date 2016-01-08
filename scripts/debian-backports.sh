#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if [ "$DISTRO" = "Debian" ]; then
  if [ "$VERSION" != "jessie" ]; then
    echo "$XMARK Only makes sense on jessie, not $VERSION"
    exit 1
  fi

  if ! grep -q backports /etc/apt/sources.list; then
    echo "$XMARK Backports not in sources.list"
    echo "  $ARROW Adding backports to in sources.list (requires sudo)"
    sudo add-apt-repository \
      "deb http://http.debian.net/debian jessie-backports main"
    echo "$CMARK Backports in sources.list, updating sources"
    sudo apt-get update
  fi
elif [ "$DISTRO" = "Ubuntu" ]; then
  # Backports comes pre-configured in Ubuntu systems these days
  true
else
  echo "$XMARK Only supported on Debian systems"
  exit 1
fi

echo "$CMARK Backports setup. Use 'apt-get -t $VERSION-backports install'"
