#/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if [ ! -f /etc/default/keyboard ]; then
  echo "$XMARK Keyboard mapping change only works on Debian-based systems"
  exit 1
fi

if ! grep -q "ctrl:nocaps" /etc/default/keyboard; then
  echo "$ARROW Mapping Caps Lock to Control (requires sudo)"
  sudo sed -i.bak 's/XKBOPTIONS=""/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
  sudo dpkg-reconfigure -phigh console-setup
fi

echo "$CMARK Caps Lock mapped to control"
