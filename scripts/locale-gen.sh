#!/bin/bash
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

installAptPackagesIfMissing locales
if ! locale -a | grep -iq "en_us.utf8"; then
  echo "$ARROW Generating locale"
  sudo locale-gen en_US.UTF-8

  # Only run in interactive shell
  if [[ $- == *i* ]]; then
    sudo dpkg-reconfigure locales
  fi
fi
echo "$CMARK Locale setup"
