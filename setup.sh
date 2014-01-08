# Install Homebrew
OS=`uname`

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

if [ $OS == "Darwin" ]; then
  # Install packages
  for p in $(cat $HOME/dotfiles/brew-packages); do
    if ! brew list $p > /dev/null; then
      brew install $p
      brew doctor
    fi
  done
  echo "Homebrew packages installed"
fi

# Install npm packages
for p in $(cat $HOME/dotfiles/npm-packages); do
  if ! npm list -g $p > /dev/null; then
    echo "Installing npm package $p"
    sudo npm install -g -q $p
  fi
done

echo "npm packages installed"

# Link missing dotfiles
for p in $(ls -ad $HOME/dotfiles/.[a-z]* | grep -v .git); do
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
