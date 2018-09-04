#!/bin/bash
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

installAptPackagesIfMissing locales
if ! locale -a | grep -iq "en_us.utf8"; then
  echo "$ARROW Generating locale"
  sudo localedef -i en_US -c -f UTF-8 en_US.UTF-8
fi
echo "$CMARK Locale setup complete"
