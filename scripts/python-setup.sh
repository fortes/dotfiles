#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"
# Make sure to pick up $VIRTUAL_ENV_DEFAULT_DIR
source "$HOME/.profile"

# Create default virtualenv
if [ ! -d "$VIRTUAL_ENV_DEFAULT_DIR" ]; then
  echo "$XMARK Default virtualenv not present"
  mkdir -p "$VIRTUAL_ENV_DEFAULT_DIR"
  echo "$ARROW Creating default virtualenv"
  virtualenv "$VIRTUAL_ENV_DEFAULT_DIR" -p "$(which python3)"
fi

echo "$CMARK Default virtualenv present"

# Activate default virtualenv to install everything via pip.
source "$VIRTUAL_ENV_DEFAULT_DIR/bin/activate"

# Install python packages
for package in $(cat $HOME/dotfiles/scripts/python-packages); do
  if [[ -z "$(pip show $package)" ]]; then
    echo "  $ARROW installing package $package"
    pip install -q -U $package
  fi
done
echo "$CMARK All python packages installed"
