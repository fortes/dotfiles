#!/bin/sh
set -ef

CMARK='✓'
XMARK='✖'
if [ -t 1 ]; then
  # Use colors in terminal
  CMARK="$(tput setaf 2)$CMARK$(tput sgr0)"
  XMARK="$(tput setaf 1)$XMARK$(tput sgr0)"
fi

# Auto-detect as much as possible about the system to make the correct
# assumptions about what should be installed
ARCH=$(uname -m)
OS=$(uname)

if [ "$OS" = "Linux" ]; then
  # Distinguish betweent Debian & Ubuntu
  if which apt-get > /dev/null 2>&1; then
    # Must have lsb_release installed for Debian/Ubuntu beforehand. Seems
    # to come on EC2 images, but not in chromebook chroots.
    if ! which lsb_release > /dev/null 2>&1; then
      echo "Installing lsb-release (requires sudo)"
      sudo apt-get -qfuy install lsb-release
    fi

    if lsb_release -d | grep -iq "ubuntu"; then
      DISTRO="Ubuntu"
    else
      # TODO: There are other debian-based distros, consider detecting?
      DISTRO="Debian"
    fi
    VERSION=$(lsb_release -s -c)
  elif [ "$(whoami)" = "chronos" ]; then
    DISTRO="Chromebook"
    VERSION="Unknown"
  else
    # Haven't bothered using other distros yet
    DISTRO="Unknown"
    VERSION="Unknown"
  fi
elif [ "$OS" = "Darwin" ]; then
  # TODO: Detect version
  DISTRO="Mac"
  VERSION="El Capitan"
else
  # What strange machine is this running on?
  DISTRO="Unknown"
  VERSION="Unknown"
fi

# Cheap way to check if we're on a machine with an active GUI, note that this
# will give a false positive if logged into the virtual console, but that's
# likely what the caller wants if they bothered to go the vconsole.
if [ -z "$DISPLAY" ]; then
  IS_HEADLESS=1
else
  IS_HEADLESS=0
fi

# Hacky way to check if we're on an EC2 machine, since this command seems to
# return something like 'us-west-2.compute.internal' in quick tests.
if hostname -d | grep -iq internal; then
  IS_EC2=1
else
  IS_EC2=0
fi

# Write variables to file
LOCAL_PROFILE="$HOME/.profile.local"
if [ ! -f "$LOCAL_PROFILE" ]; then
  {
    echo "# Generated $(date +%F)"
    echo "export ARCH=$ARCH"
    echo "export OS=$OS"
    echo "export DISTRO=$DISTRO"
    echo "export VERSION=$VERSION"
    echo "export IS_HEADLESS=$IS_HEADLESS"
    echo "export IS_EC2=$IS_EC2"
    echo ""
    echo "# Add machine-specific items below"
    echo "# LAST_FM_USERNAME=xxx"
    echo "# LAST_FM_PASSWORD=xxx"
    echo "# etc ..."
  } > "$LOCAL_PROFILE"

  echo "$CMARK Config file written to $LOCAL_PROFILE:"
  . "$LOCAL_PROFILE"
else
  echo "$CMARK $LOCAL_PROFILE already exists"
fi
unset LOCAL_PROFILE

DOTFILES="$HOME/dotfiles"

# First, we need to make sure we have the bare minimums to install things on
# this system
if [ "$OS" = "Darwin" ]; then
  # First time running Make on MacOS requires agreeing to a license agreement,
  # which you must agree to via sudo.
  #
  # If run make after doing the agreement (or on a sane system), you'll get a
  # message that looks like:
  #
  #   make: *** No targets specified and no makefile found. Stop.
  #
  # Note that this goes out on stderr, so we pipe stderr to stdout to grep
  if make > /dev/null 2>&1 | grep -qv 'no makefile'; then
    echo "$XMARK Must agree to license agreement"
    echo "Run 'sudo make' then try this script again"
    exit 1
  fi

  # For Mac OS, that means we need to get Homebrew installed, along with the
  # XCode build tools, if necessary
  if ! which brew > /dev/null; then
    # El Capitan no longer lets /usr/local be writable, change that
    echo "Changing ownership of /usr/local to $(whoami) (requires sudo)"
    sudo chown -R "$(whoami):admin" /usr/local
    # Install Homebrew
    echo "Homebrew not installed. Installing (will take a while) ..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  echo "$CMARK Homebrew installed"

  # Finally, make sure we have git
  if ! which git > /dev/null; then
    echo "Installing git ..."
    brew install git
  fi
  echo "$CMARK Git installed"
elif [ "$OS" = "Linux" ] && which apt-get > /dev/null 2>&1; then
  # Make sure git is in there
  if ! which git > /dev/null; then
    echo "Installing git (requires sudo)..."
    sudo apt-get -qfuy install git
  fi
  echo "$CMARK Git installed"
elif [ "$DISTRO" = "Chromebook" ]; then
  echo "Downloading crouton script to $HOME"
  wget "https://goo.gl/fd3zc" -O "$HOME/crouton"
  echo "Installing crouton bin tools (requires sudo)"
  sudo sh "$HOME/crouton" -b
else
  echo "$XMARK Sorry, but your system ($OS) is not supported"
  exit 1
fi

if [ $DISTRO = "Chromebook" ]; then
  # Chromebook is pretty restricted, so let's do the bare minimum here and rely
  # on crouton for the rest
  DOTFILES_TARBALL="https://github.com/fortes/dotfiles/archive/master.tar.gz"
  if [ -d "$DOTFILES" ]; then
    rm -rf "$HOME/dotfiles.old"
    echo "Moving previous ~/dotfiles to ~/dotfiles.old"
    mv "$DOTFILES" "$DOTFILES".old
  fi

  if [ ! -d "$DOTFILES" ]; then
    wget "$DOTFILES_TARBALL" -O "$HOME/dotfiles.tar.gz"
    mkdir -p "$DOTFILES"
    echo "Downloading latest dotfiles to $DOTFILES"
    tar zxf "$HOME/dotfiles.tar.gz" -C "$DOTFILES" --strip-components=1
    rm "$HOME/dotfiles.tar.gz"
  fi
else
  # Pull down the full repo
  if [ ! -d "$DOTFILES" ]; then
    echo "Cloning dotfiles repo to $DOTFILES"
    git clone http://github.com/fortes/dotfiles "$DOTFILES" > /dev/null
  else
    echo "Pulling latest dotfiles..."
    (cd "$DOTFILES" && git pull 2> /dev/null || true)
  fi
fi
echo "$CMARK ~/dotfiles present"

# Now run the main setup now that we have the repo, etc
. "$HOME/dotfiles/scripts/setup-machine.sh"
