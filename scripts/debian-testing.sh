#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if [ "$DISTRO" = "Debian" ]; then
  if [ "$VERSION" != "jessie" ]; then
    echo "$XMARK Only makes sense on jessie, not $VERSION"
    exit 1
  fi

  if ! grep -q testing /etc/apt/sources.list; then
    echo "$XMARK Testing not in sources.list"
    echo "  $ARROW Adding testing to in sources.list (requires sudo)"
    sudo add-apt-repository -y \
      "deb http://ftp.us.debian.org/debian testing main contrib non-free"
    sudo add-apt-repository -y \
      "deb http://security.debian.org testing/updates main contrib non-free"
    echo "  $ARROW Adding default release to /etc/apt/apt.conf (requires sudo)"
    echo "APT::Default-Release \"$VERSION\";" | sudo tee -a /etc/apt/apt.conf
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

echo "$CMARK Testing sources setup. Use 'apt-get -t testing install'"

