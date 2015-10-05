#!/bin/bash
set -eo pipefail

OS=`uname`

source $HOME/dotfiles/scripts/helpers.sh

if [ -z "${HEADLESS-}" ]; then
  HEADLESS=''
fi

# Install Homebrew
if [ $OS == "Darwin" ]; then
  # Brew cask
  if ! isHomebrewTapInstalled caskroom/cask; then
    echo "$XMARK Caskroom not setup"
    echo "  $ARROW Tapping & installing caskroom"
    # brew tap caskroom/cask
    # brew install brew-cask
    # brew cask
  fi
  echo "$CMARK Homebrew cask setup"
elif [ $OS == "Linux" ]; then
  if ! which apt-get > /dev/null; then
    echo "$XMARK Non-apt setup not supported"
    return 1
  fi

  # Make sure not to get stuck on any prompts
  export DEBIAN_FRONTEND=noninteractive

  # if ! which git > /dev/null; then
  #   echo "Installing pre-requisites first (requires sudo)"
  #   sudo -E apt-get update -q > /dev/null && \
  #   sudo -E apt-get dist-upgrade -qfuy > /dev/null && \
  #   sudo -E apt-get install -qfuy git build-essential \
  #     libssl-dev python-software-properties > /dev/null
  # fi
  # echo "Git and build tools installed"

  PPA_ADDED=0
  # if [ ! -f /etc/apt/sources.list.d/chris-lea-node_js-trusty.list ]; then
  #   echo "Adding Node PPA (requires sudo)"
  #   PPA_ADDED=1
  #   sudo -E add-apt-repository -y ppa:chris-lea/node.js > /dev/null
  # fi

  # if [ ! -f /etc/apt/sources.list.d/jon-severinsson-ffmpeg-trusty.list ]; then
  #   echo "Adding ffmpeg PPA (requires sudo)"
  #   PPA_ADDED=1
  #   sudo -E add-apt-repository -y ppa:jon-severinsson/ffmpeg > /dev/null
  # fi

  # if [ ! -n $HEADLESS ]; then
  #   if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
  #     echo "Adding Chrome PPA (requires sudo)"
  #     PPA_ADDED=1
  #     wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - > /dev/null
  #     sudo -E sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
  #   fi
  # fi

  # Update sources if we added a PPA
  if [ $PPA_ADDED ]; then
    sudo -E apt-get -q update > /dev/null
  fi
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
  if [ ! -n "$(brew list python 2> /dev/null)" ]; then
    brew install python --with-brewed-openssl
    pip install -q --upgrade setuptools
    pip install -q --upgrade pip
    pip install -q --upgrade virtualenv
    echo "Python installed"

    # Python3 bonus
    brew install python3 --with-brewed-openssl
    pip3 install -q --upgrade setuptools
    pip3 install -q --upgrade pip
    echo "Python3 installed"
  fi

  brew doctor
  brew update
  for p in $(cat $HOME/dotfiles/scripts/brew-packages); do
    if [ ! -n "$(brew list $p 2> /dev/null)" ]; then
      brew install $p

      if [$p == 'fzf']; then
        echo "Setting up fzf"
        $(brew info fzf | grep /install)
      fi

      # Update source paths, etc
      . $HOME/.bashrc
    fi
  done
  echo "Homebrew packages installed"

  # Install cask packages
  brew cask doctor
  brew cask update
  for p in $(cat $HOME/dotfiles/scripts/cask-packages); do
    if [ ! -n "$(brew cask list $p 2> /dev/null)" ]; then
      brew cask install $p
      # Update source paths, etc
      source ~/.profile
    fi
  done
  echo "Cask packages installed"
elif [ $OS == "Linux" ]; then
  # Different apt packages if we don't have a GUI
  PACKAGE_FILE=$HOME/dotfiles/scripts/apt-packages
  if [ -n $HEADLESS ]; then
    PACKAGE_FILE=$HOME/dotfiles/scripts/apt-packages-headless
  fi

  for p in $(cat $PACKAGE_FILE); do
    if ! isAptPackageInstalled $p; then
      echo "$XMARK Apt package $p not installed"
      echo "  $ARROW Installing $p (requires sudo)"
      sudo -E apt-get install -qfuy $p > /dev/null
    fi
    echo "$CMARK $p installed"
  done

  # Update source paths, etc
  source ~/.profile
  echo "$CMARK apt packages installed"
fi

($HOME/dotfiles/scripts/python-setup.sh)

($HOME/dotfiles/scripts/node-setup.sh)

# Make sure ~/.ssh exists
mkdir -p $HOME/.ssh
# Link missing dotfiles
($HOME/dotfiles/scripts/link-dotfiles.sh -f)

# Setup shell
($HOME/dotfiles/scripts/zsh-setup.sh)

# Neovim setup
($HOME/dotfiles/scripts/nvim-setup.sh)
