#!/bin/sh
set -ef

OS=`uname`
CMARK='✓'
XMARK='✖'

if [ -t 1 ]; then
  # Use colors in terminal
  CMARK="$(tput setaf 2)$CMARK$(tput sgr0)"
  XMARK="$(tput setaf 1)$XMARK$(tput sgr0)"
fi

# First, we need to make sure we have the bare minimums to install things on
# this system
if [ $OS = "Darwin" ]; then
  # For Mac OS, that means we need to get Homebrew installed, along with the
  # XCode build tools, if necessary
  if ! which brew > /dev/null; then
    # First time running Make on MacOS requires agreeing to a license agreement,
    # which you must agree to via sudo.
    #
    # If run make after doing the agreement (or on a sane system), you'll get a
    # message that looks like:
    #
    #   make: *** No targets specified and no makefile found. Stop.
    #
    # Note that this goes out on stderr, so we pipe stderr to stdout
    # TODO: Fix this, since the error code from make is non-zero, so it'll never
    # get triggered. Need to do another method.
    if [ -n "$(make 2>&1 > /dev/null | grep -v 'no makefile')" ]; then
      echo "$XMARK Must agree to license agreement"
      echo "Run 'sudo make' then try this script again"
      exit 1
    fi

    # Install Homebrew
    echo "Homebrew not installed. Installing (will take a while) ..."
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  fi
  echo "$CMARK Homebrew installed"

  # Finally, make sure we have git
  if ! which git > /dev/null; then
    echo "Installing git ..."
    brew install git
  fi
  echo "$CMARK Git installed"
elif [ $OS = "Linux" ] && which apt-get > /dev/null; then
  # Make sure git is in there
  if ! which git > /dev/null; then
    echo "Installing git (requires sudo)..."
    sudo apt-get install -qfuy git
  fi
  echo "$CMARK Git installed"
else
  echo "$XMARK Sorry, but your system ($OS) is not supported"
  exit 1
fi

# Pull down the full repo
if [ ! -d $HOME/dotfiles ]; then
  echo "Cloning dotfiles repo to $HOME/dotfiles"
  git clone http://github.com/fortes/dotfiles $HOME/dotfiles > /dev/null
else
  echo "Pulling latest dotfiles..."
  (cd $HOME/dotfiles && git pull 2>&1 2> /dev/null || true)
fi
echo "$CMARK ~/dotfiles present"

# Now run the main setup now that we have the repo, etc
source $HOME/dotfiles/scripts/setup-machine.sh
