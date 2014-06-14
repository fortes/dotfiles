#!/bin/bash
OS=`uname`

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
elif [ $OS == "Linux" ]; then
  echo "Linux not implemented yet"
fi

# Check dotfiles
if [ ! -d $HOME/dotfiles ]; then
  git clone http://github.com/fortes/dotfiles $HOME/dotfiles
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

  for p in $(cat $HOME/dotfiles/brew-packages); do
    if [ ! -n "$(brew list $p 2> /dev/null)" ]; then
      brew install $p
      brew doctor
      brew update
      # Update source paths, etc
      . ~/.bashrc
    fi
  done
  echo "Homebrew packages installed"
fi

# Create default virtualenv
if [ ! -d ~/virtualenvs/default ]; then
  echo "Creating default virtualenv"
  mkdir -p ~/virtualenvs/
  rm -rf ~/virtualenvs/*
  # Now create the default virtualenv
  virtualenv ~/virtualenvs/default
  echo "Default virtualenv created"
fi

# Always activate default virtualenv, since we will install via pip
PROMPT=$PS1
source ~/virtualenvs/default/bin/activate
PS1=$PROMPT

# Install python packages
for p in $(cat $HOME/dotfiles/python-packages); do
  pip install -q -U $p
done
echo "python packages installed"

# Install npm packages
for p in $(cat $HOME/dotfiles/npm-packages); do
  if ! npm list -g $p > /dev/null; then
    echo "Installing global npm package $p (requires sudo)"
    sudo npm install -g -q $p
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
  git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
  echo "NeoBundle installed"
fi
# Install all bundles via CLI
vim +NeoBundleUpdate +qall
echo "Vim setup"
