#!/bin/bash
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

installAptPackagesIfMissing locales
if ! locale -a | grep -iq "en_us.utf8"; then
  echo "$ARROW Generating locale"
  sudo locale-gen en_US.UTF-8 && sudo dpkg-reconfigure locales
fi
echo "$CMARK Locale setup"
