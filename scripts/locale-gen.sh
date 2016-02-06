#!/bin/bash
source "$HOME/dotfiles/scripts/helpers.sh"

installAptPackagesIfMissing locales
if locale | grep -iq posix; then
  echo "$ARROW Generating locale"
  sudo locale-gen en_US.UTF-8 && sudo dpkg-reconfigure locales
fi
echo "$CMARK Locale setup"
