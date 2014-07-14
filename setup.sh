#!/bin/bash
OS=`uname`

# Error out if any command fails
set -e

# Install Homebrew
if [ $OS == "Darwin" ]; then
  if [ ! -x /usr/local/bin/brew ]; then
    # There is a license agreement before you can run make, and you have to
    # agree to it via sudo. This command checks for normal the normal make
    # output when there is no Makefile:
    #   make: *** No targets specified and no makefile found. Stop.
    # Note that this goes out on stderr, so we pipe stderr to stdout
    if [[ -z $(make 2>&1 >/dev/null | grep "no makefile") ]]; then
      echo "Must agree to make license agreement. Run 'sudo make' first"
      exit 1
    fi
    # Install Homebrew
    echo "Homebrew not installed. Installing:"
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  else
    echo "Homebrew already installed"
  fi

  # Brew cask
  if [[ -z $(brew tap | grep caskroom/cask) ]]; then
    echo "Caskroom not setup. Tapping & installing"
    brew tap caskroom/cask
    brew install brew-cask
    brew cask
  fi
elif [ $OS == "Linux" ]; then
  if ! hash aptitude 2> /dev/null; then
    echo "Non-apt setup not supported"
    exit
  fi

  if ! hash git 2> /dev/null; then
    echo "Installing pre-requisites first (requires sudo)"
    sudo aptitude update && \
    sudo aptitude install -q -y git build-essential libssl-dev python-software-properties
  fi
  echo "Git and build tools installed"

  echo "Adding Node PPA (requires sudo)"
  sudo add-apt-repository -y ppa:chris-lea/node.js
fi

# Check dotfiles
if [ ! -d $HOME/dotfiles ]; then
  git clone http://github.com/fortes/dotfiles $HOME/dotfiles
  # Make sure to link .bashrc, else some annoying errors happen
  if [ ! -e $HOME/.bashrc ]; then
    ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc
  fi
fi
echo "dotfiles repo present"

# Mac OS Settings
if [ $OS == "Darwin" ]; then
  # Show percent remaining for battery
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"

  # Don't require password right away after sleep
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 300

  # Show all filename extensions in Finder
  #defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi

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
  for p in $(cat $HOME/dotfiles/brew-packages); do
    if [ ! -n "$(brew list $p 2> /dev/null)" ]; then
      brew install $p
      # Update source paths, etc
      . $HOME/.bashrc
    fi
  done
  echo "Homebrew packages installed"

  # Install cask packages
  brew cask doctor
  brew cask update
  for p in $(cat $HOME/dotfiles/cask-packages); do
    if [ ! -n "$(brew cask list $p 2> /dev/null)" ]; then
      brew cask install $p
      # Update source paths, etc
      . $HOME/.bashrc
    fi
  done
  echo "Cask packages installed"
elif [ $OS == "Linux" ]; then
  echo "Updating apt (requires sudo)"
  sudo aptitude update
  for p in $(cat $HOME/dotfiles/apt-packages); do
    if ! dpkg -s $p > /dev/null; then
      echo "Installing missing package $p"
      sudo aptitude install -q -y $p
    fi
  done
  # Update source paths, etc
  . $HOME/.bashrc
  echo "apt packages installed"
fi

# Create default virtualenv
if [ ! -d $HOME/virtualenvs/default ]; then
  echo "Creating default virtualenv"
  mkdir -p $HOME/virtualenvs/
  rm -rf $HOME/virtualenvs/*
  # Now create the default virtualenv
  virtualenv $HOME/virtualenvs/default
  echo "Default virtualenv created"
fi

# Always activate default virtualenv, since we will install via pip
PROMPT=$PS1
source $HOME/virtualenvs/default/bin/activate
PS1=$PROMPT

# Install python packages
for p in $(cat $HOME/dotfiles/python-packages); do
  pip install -q -U $p
done
echo "python packages installed"

# Install npm packages
for p in $(cat $HOME/dotfiles/npm-packages); do
  if ! npm list -g $p > /dev/null; then
    echo "Installing global npm package $p"
    npm install -g -q $p
  fi
done
echo "npm packages installed"

# Link missing dotfiles
for p in $(ls -ad $HOME/dotfiles/.[a-z]* | grep -v .git/$ | grep -v .git$); do
  target_f=$HOME/`basename $p`
  if [ ! -e $target_f ]; then
    echo "Linking $target_f"
    ln -s $p $target_f
  fi
done
echo "dotfiles linked"

# Setup Vundle & Vim
if [ ! -d $HOME/.vim/bundle/neobundle.vim ]; then
  echo "Installing NeoBundle for Vim"
  mkdir -p $HOME/.vim/bundle
  git clone https://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
  echo "NeoBundle installed"
fi
# Install all bundles via CLI
vim +NeoBundleUpdate +qall
echo "Vim setup"
