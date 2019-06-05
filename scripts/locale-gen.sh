#!/bin/bash
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

installAptPackagesIfMissing locales
if ! locale -a | grep -iq "en_us.utf8"; then
  echo "$ARROW Generating locale"
  sudo localedef -i en_US -c -f UTF-8 en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8
fi

if locale | grep LANGUAGE | grep -iq "en_us.utf8"; then
  sudo dpkg-reconfigure locales
fi

echo "$CMARK Locale setup complete"
