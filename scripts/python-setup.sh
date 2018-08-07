#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"
# Pick up $PYENV_ROOT
source "$HOME/dotfiles/symlinks/bashrc"

# Install pyenv and pyenv-virtualenv
if ! command -v pyenv > /dev/null; then
  if [ ! -d "$PYENV_ROOT" ]; then
    echo "  $ARROW Cloning pyenv repository"
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
  else
    echo "$XMARK pyenv not installed but installation directory already present"
    # exit 1
  fi

  echo "$ARROW Installing build dependencies (requires sudo)"
  sudo apt-get -qqfuy install make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev
fi

if [ -d "$PYENV_ROOT" ]; then
  echo "$ARROW Updating pyenv"
  pushd "$PYENV_ROOT" > /dev/null
  git pull > /dev/null
  popd > /dev/null
fi

PYENV_VIRTUALENV_DIR="$PYENV_ROOT/plugins/pyenv-virtualenv"
if [ ! -d $PYENV_VIRTUALENV_DIR ]; then
  echo "$ARROW Installing pyenv-virtualenv"
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_VIRTUALENV_DIR"
fi

# Install python packages
echo "$ARROW Installing/upgrading pip packages"
pip3 install -q -U --user $(xargs < $HOME/dotfiles/scripts/python-packages)

echo "$CMARK All python packages installed"
