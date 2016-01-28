#/bin/bash
set -euf
source "$HOME/dotfiles/scripts/helpers.sh"

if [ "$OS" = "Linux" ]; then
  echo "$ARROW (Re-)installing beets and dependencies (requires sudo)"
  sudo apt-get -qqfuy install mp3val
  pip install -U beautifulsoup4 beets flask pyacoustid pylast requests
  echo "$CMARK Everything installed"
else
  echo "$XMARK Unsupported OS"
  exit 1
fi
