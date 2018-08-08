#! /bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

MULTIMEDIA_FILE=/etc/apt/sources.list.d/debian-multimedia.list
if [ ! -f $MULTIMEDIA_FILE ]; then
  echo "$XMARK Debian Multimedia not in sources.list"
  echo "  $ARROW Adding backports to in sources.list (requires sudo)"
  # TODO: Use `apt-key add`?
  echo "deb http://www.deb-multimedia.org stretch main non-free" | \
    sudo tee $MULTIMEDIA_FILE
  echo "$CMARK Multimedia in sources.list, updating sources"
  sudo apt-get update -oAcquire::AllowInsecureRepositories=true -qq
  echo "$ARROW Getting keyring for Multimedia"
  sudo apt-get install deb-multimedia-keyring -oAcquire::AllowInsecureRepositories=true
fi

echo "$CMARK Multimedia repository setup"
