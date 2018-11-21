#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"
# Make sure to pick up pyenv settings before install fully complete
source "$HOME/dotfiles/stowed-files/bash/.profile"

# Install pyenv and pyenv-virtualenv
if ! command -v pyenv > /dev/null; then
  if [ ! -d "$PYENV_ROOT" ]; then
    echo "  $ARROW Cloning pyenv repository"
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
  else
    echo "$XMARK pyenv not installed but installation directory already present"
    exit 1
  fi

  echo "$ARROW Installing pyenv build dependencies (requires sudo)"
  sudo DEBIAN_FRONTEND=noninteractive apt-get -qqfuy install make \
    build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev
fi

if [ -d "$PYENV_ROOT" ]; then
  echo "$ARROW Updating pyenv"
  pushd "$PYENV_ROOT" > /dev/null
  git pull > /dev/null
  popd > /dev/null
else
  echo "$XMARK pyenv directory does not exist"
  exit 1
fi

PYENV_VIRTUALENV_DIR="$PYENV_ROOT/plugins/pyenv-virtualenv"
if [ ! -d $PYENV_VIRTUALENV_DIR ]; then
  echo "$ARROW Installing pyenv-virtualenv"
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_VIRTUALENV_DIR"
fi

# May need to update now that pyenv, etc are in path and latest
source "$HOME/dotfiles/stowed-files/bash/.profile"

echo "$ARROW Setting python version via pyenv"
pyenv install -s "$PYENV_VERSION"
pyenv global "$PYENV_VERSION"

# Install python packages, but make sure pip and setuptools are latest first
echo "$ARROW Installing/upgrading pip packages"
pip install -q --upgrade pip setuptools
pip install -q --upgrade $(xargs < $HOME/dotfiles/scripts/python-packages)

echo "$CMARK All python packages installed"
echo "$CMARK Python setup complete"
