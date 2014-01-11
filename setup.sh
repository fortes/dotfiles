OS=`uname`

# Install Homebrew
if [ $OS == "Darwin" ]; then
  if [ ! -x /usr/local/bin/brew ]; then
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
    pip install --upgrade setuptools
    pip install --upgrade pip
    pip install virtualenv
    # Python3 bonus
    brew install python3 --with-brewed-openssl
    pip3 install --upgrade setuptools
    pip3 install --upgrade pip
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

# Install python packages
for p in $(cat $HOME/dotfiles/python-packages); do
  if [ ! -n "$(pip show $p)" ]; then
    echo "Installing pip package $p"
    pip install $p
  fi
done
echo "python packages installed"

# Install npm packages
for p in $(cat $HOME/dotfiles/npm-packages); do
  if ! npm list -g $p > /dev/null; then
    echo "Installing npm package $p"
    sudo npm install -g -q $p
  fi
done
echo "npm packages installed"

# Link missing dotfiles
for p in $(ls -ad $HOME/dotfiles/.[a-z]* | grep -v .git/$); do
  target_f=$HOME/`basename $p`
  if [ ! -e $target_f ]; then
    echo "Linking $target_f"
    ln -s $p $target_f
  fi
done
echo "dotfiles linked"

# Setup Vundle & Vim
if [ ! -d $HOME/.vim/bundle/vundle ]; then
  echo "Installing Vundle for Vim"
  mkdir -p $HOME/.vim/
  git clone https://github.com/gmarik/vundle.git $HOME/.vim/bundle/vundle
  # Install all bundles via CLI
  vim +BundleInstall +qall
fi
echo "Vim setup"
