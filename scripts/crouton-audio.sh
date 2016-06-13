#!/bin/bash
set -euf
source "$HOME/dotfiles/scripts/helpers.sh"

installAptPackagesIfMissing alsa-oss pulseaudio pulseaudio-utils

if groups "$(whoami)" | grep -qiv pulse; then
  echo "$ARROW Adding $USER to pulse group (requires sudo)"
  sudo usermod -aG pulse,pulse-access "$(whoami)"
fi

echo "$CMARK $USER in pulse groups. May need to login again"
