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

commandExists() {
  command -v "$1" &> /dev/null
}

if [ "$OS" = "Linux" ]; then
  # Distinguish betweent Debian & Ubuntu
  if commandExists apt-get; then
    # Must have lsb_release installed for Debian/Ubuntu beforehand. Seems
    # to come on EC2 images
    if ! commandExists lsb_release; then
      echo "Installing lsb-release (requires sudo)"
      sudo DEBIAN_FRONTEND=noninteractive apt-get -qqfuy install lsb-release
    fi

    if lsb_release -d | grep -iq "ubuntu"; then
      DISTRO="Ubuntu"
    else
      # TODO: There are other debian-based distros, consider detecting?
      DISTRO="Debian"
    fi
    VERSION=$(lsb_release -s -c)
  else
    # Haven't bothered using other distros yet
    DISTRO="Unknown"
    VERSION="Unknown"
  fi
elif [ "$OS" = "Darwin" ]; then
  echo "$XMARK Mac OS X no longer supported"
  exit 1
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

if commandExists croutonversion; then
  IS_CROUTON=1
  if croutonversion | grep -q xorg; then
    IS_HEADLESS=0
  fi
else
  IS_CROUTON=0
fi

if grep -q Microsoft /proc/version; then
  IS_WSL=1
else
  IS_WSL=0
fi

# Slightly hacky way to see if we are within a Docker container
if [ -f /.dockerenv ]; then
  IS_DOCKER=1

  # `resolvconf` leads to all sorts of failures inside of Docker, so just punt
  echo "resolvconf resolvconf/linkify-resolvconf boolean false" | \
    sudo debconf-set-selections
else
  IS_DOCKER=0
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
    echo "export IS_CROUTON=$IS_CROUTON"
    echo "export IS_DOCKER=$IS_DOCKER"
    echo "export IS_EC2=$IS_EC2"
    echo "export IS_HEADLESS=$IS_HEADLESS"
    echo "export IS_WSL=$IS_WSL"
    echo ""
    echo "# Add machine-specific items below"
    echo "# export LAST_FM_USERNAME=xxx"
    echo "# export LAST_FM_PASSWORD=xxx"
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
if [ "$OS" = "Linux" ] && commandExists apt-get; then
  # Don't want installs to wait on user interaction
  export DEBIAN_FRONTEND=noninteractive

  if ! commandExists add-apt-repository; then
    echo "Installing software-properties-common (requires sudo)"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qqfuy install software-properties-common
  fi

  if [ "$DISTRO" = "Debian" ]; then
    echo "Adding contrib & non-free to sources (requires sudo)"
    sudo add-apt-repository -y contrib > /dev/null
    sudo add-apt-repository -y non-free > /dev/null
  elif [ "$DISTRO" = "Ubuntu" ]; then
    echo "Adding restricted, universe, and multiverse to sources (requires sudo)"
    sudo add-apt-repository -y restricted > /dev/null
    sudo add-apt-repository -y universe > /dev/null
    sudo add-apt-repository -y multiverse > /dev/null
  fi

  # Make sure git is in there
  if ! commandExists git; then
    echo "Installing git (requires sudo)..."
    # If git isn't here, then this is the first time running, likely need to
    # update all sources
    sudo apt-get -qq update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qqfuy install git
  fi
  echo "$CMARK Git installed"
else
  echo "$XMARK Sorry, but your system ($OS) is not supported"
  exit 1
fi

# Pull down the full repo
if [ ! -d "$DOTFILES" ]; then
  echo "Cloning dotfiles repo to $DOTFILES"
  git clone http://github.com/fortes/dotfiles "$DOTFILES" > /dev/null
else
  echo "Pulling latest dotfiles..."
  (cd "$DOTFILES"; git pull 2> /dev/null || true)
fi
echo "$CMARK ~/dotfiles present"

# Now run the main setup now that we have the repo, etc
. "$HOME/dotfiles/scripts/setup-machine.sh"
