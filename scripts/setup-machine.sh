#!/bin/bash
set -eo pipefail

# Make sure to load OS/Distro/etc variables
source $HOME/.profile.local
source $HOME/dotfiles/scripts/helpers.sh

# Install Homebrew
if [ $OS == "Darwin" ]; then
  # Brew cask
  if ! isHomebrewTapInstalled caskroom/cask; then
    echo "$XMARK Caskroom not setup"
    echo "  $ARROW Tapping & installing caskroom"
    brew tap caskroom/cask
    brew install brew-cask
    brew cask
  fi
  echo "$CMARK Homebrew cask setup"
elif [ $DISTRO = "Chromebook" ]; then
  echo "$XMARK Chromebook setup not complete yet"
  return 1
elif [ $OS == "Linux" ]; then
  if ! command -v apt-get > /dev/null; then
    echo "$XMARK Non-apt setup not supported"
    return 1
  fi

  # Make sure not to get stuck on any prompts
  DEBIAN_FRONTEND=noninteractive
fi

# Mac OS Settings
# if [ $OS == "Darwin" ]; then
#   # Show percent remaining for battery
#   defaults write com.apple.menuextra.battery ShowPercent -string "YES"
#
#   # Don't require password right away after sleep
#   defaults write com.apple.screensaver askForPassword -int 1
#   defaults write com.apple.screensaver askForPasswordDelay -int 300
#
#   # Show all filename extensions in Finder
#   #defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# fi

# Install homebrew packages
if [ $OS == "Darwin" ]; then
  # Install python with up-to-date OpenSSL
  if ! isHomebrewPackageInstalled python; then
    brew install python --with-brewed-openssl
    pip install -q --upgrade setuptools
    pip install -q --upgrade pip
    pip install -q --upgrade virtualenv
    echo "$CMARK Python installed"
  fi

  brew update
  brew doctor
  for p in $(cat $HOME/dotfiles/scripts/brew-packages); do
    installHomebrewPackageIfMissing $p
  done
  echo "$CMARK Homebrew packages installed"

  # Install cask packages
  brew cask doctor
  brew cask update
  for p in $(cat $HOME/dotfiles/scripts/cask-packages); do
    if [ ! -n "$(brew cask list $p 2> /dev/null)" ]; then
      echo "$XMARK $p not installed"
      echo "  $ARROW Installing $p via brew"
      brew cask install $p
    fi
  done
  echo "$CMARK Cask packages installed"
elif [ $OS == "Linux" ]; then
  PACKAGES=`cat $HOME/dotfiles/scripts/apt-packages-headless`
  if [ -z $IS_HEADLESS ]; then
    # GUI-only packages
    PACKAGES="$PACKAGES
$(cat $HOME/dotfiles/scripts/apt-packages)"
  fi

  for p in $PACKAGES; do
    installAptPackageIfMissing $p
  done
  echo "$CMARK apt packages installed"
fi

# Link missing dotfiles
($HOME/dotfiles/scripts/link-dotfiles.sh -f)

# Update source paths, etc
source ~/.profile

($HOME/dotfiles/scripts/python-setup.sh)

($HOME/dotfiles/scripts/node-setup.sh)

# Setup shell
($HOME/dotfiles/scripts/zsh-setup.sh)

# cmus
if [ -z $IS_HEADLESS ]; then
  ($HOME/dotfiles/scripts/cmus-setup.sh)
fi

# FZF
($HOME/dotfiles/scripts/fzf-setup.sh)

# Neovim setup
($HOME/dotfiles/scripts/nvim-setup.sh)
