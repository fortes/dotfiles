#!/bin/bash
set -eo pipefail

# Make sure to load OS/Distro/etc variables
source "$HOME/.profile.local"
source "$HOME/dotfiles/scripts/helpers.sh"

if [ "$DISTRO" = "Chromebook" ]; then
  echo "$XMARK Chromebook setup not complete yet"
  return 1
elif [ "$OS" == "Linux" ]; then
  if ! command -v apt-get > /dev/null; then
    echo "$XMARK Non-apt setup not supported"
    return 1
  fi

  # Make sure not to get stuck on any prompts
  export DEBIAN_FRONTEND=noninteractive
fi

if [ "$IS_EC2" != 1 ] && [ "$IS_DOCKER" != 1 ]; then
  ("$HOME/dotfiles/scripts/debian-keyboard.sh" || true)
fi

if [ "$IS_CROUTON" == 1 ]; then
  "$HOME/dotfiles/scripts/locale-gen.sh"
fi

PACKAGES=$(xargs < "$HOME/dotfiles/scripts/apt-packages-headless")
if [ "$IS_HEADLESS" != 1 ]; then
  # GUI-only packages
  PACKAGES="$PACKAGES $(xargs < "$HOME/dotfiles/scripts/apt-packages")"
fi

installAptPackagesIfMissing "$PACKAGES"
echo "$CMARK apt packages installed"

# Link missing dotfiles
("$HOME/dotfiles/scripts/link-dotfiles.sh" -f)

# Update source paths, etc
source ~/.profile
source ~/.bashrc

("$HOME/dotfiles/scripts/python-setup.sh")

("$HOME/dotfiles/scripts/node-setup.sh")

# cmus
if [ "$IS_HEADLESS" != 1 ]; then
  ("$HOME/dotfiles/scripts/cmus-setup.sh")
fi

# FZF
("$HOME/dotfiles/scripts/fzf-setup.sh")

# Neovim setup
("$HOME/dotfiles/scripts/nvim-setup.sh")
