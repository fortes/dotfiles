#!/bin/bash
set -ef -o pipefail
# shellcheck source=/home/fortes/dotfiles/scripts/helpers.sh
# shellcheck disable=SC1091
source "$HOME/dotfiles/scripts/helpers.sh"

if [ ! -f /etc/default/keyboard ]; then
  echo "$XMARK Keyboard mapping change only works on Debian-based systems"
  exit 1
fi

if ! grep -q "ctrl:nocaps" /etc/default/keyboard; then
  echo "$ARROW Mapping Caps Lock to Control (requires sudo)"
  sudo sed -i.bak 's/^XKBOPTIONS=""/XKBOPTIONS="altwin:left_meta_win,ctrl:nocaps"/' /etc/default/keyboard

  if [ "$IS_CROUTON" == 1 ]; then
    echo "$ARROW Using crouton keyboard (requires sudo)"
    sudo sed -i.bak 's/^XKBMODEL=".*"$/XKBMODEL="chromebook"/' /etc/default/keyboard
  fi

  if isAptPackageInstalled console-setup; then
    sudo dpkg-reconfigure -phigh console-setup
  fi
fi

echo "$CMARK Caps Lock mapped to control"
