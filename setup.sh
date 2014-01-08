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

  # Install packages
  for p in $(cat $HOME/dotfiles/brew-packages); do
    if ! brew list $p > /dev/null; then
      brew install $p
    fi
  done

  echo "Homebrew packages installed"

  # Checkout

  echo "dotfiles linked"
elif [ $OS == "Linux" ]; then
  echo "Linux not implemented yet"
fi

# Clone dotfiles

# Link missing dotfiles
for p in $(ls -ad ~/dotfiles/.[a-z]* | grep -v .git); do
  target_f=~/`basename $p`
  if [ ! -e $target_f ]; then
    echo "Linking $target_f"
    ln -s $p $target_f
  fi
done

# Setup Vundle & Vim
if [ ! -d ~/.vim/bundle/vundle ]; then
  echo "Installing Vundle for Vim"
  mkdir -p ~/.vim/
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
  # Install all bundles via CLI
  vim +BundleInstall +qall
fi
