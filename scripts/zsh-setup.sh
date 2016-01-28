#!/bin/bash
set -euf -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

# Make sure we are using zsh
if [ "$(command -v zsh)" != "$SHELL" ]; then
  echo "$XMARK Shell is not zsh"
  if [ "$OS" == "Darwin" ]; then
    # Get latest zsh from homebrew
    installHomebrewPackagesIfMissing zsh
    ZSH_LOCATION="$(command -v zsh)"

    if ! grep -q "$ZSH_LOCATION" /etc/shells; then
      echo "Adding homebrew zsh to accepted shell list (requires sudo)"
      sudo sh -c "$ZSH_LOCATION >> /etc/shells"
    fi
  elif command -v apt-get > /dev/null; then
    installAptPackagesIfMissing zsh
  else
    echo "  $XMARK Unsupported OS. Install zsh on your own"
    exit 1
  fi

  ZSH_LOCATION="$(command -v zsh)"

  if [ "$IS_EC2" = 1 ] || [ "$IS_DOCKER" = 1 ]; then
    echo "$XMARK Cannot change shell on password-less users (e.g. EC2 default)"
    exit 0
  else
    echo "  $ARROW Switching shell to zsh (will prompt for password)"
    chsh -s "$ZSH_LOCATION"

    echo "$CMARK zsh shell will be active in a terminals/login"
    exit 0
  fi
fi

echo "$CMARK Shell is zsh"
