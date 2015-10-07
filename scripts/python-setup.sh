#!/bin/bash
set -ef -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

# Create default virtualenv
if [ ! -d $HOME/virtualenvs/default ]; then
  echo "$XMARK Default virtualenv not present"
  mkdir -p $HOME/virtualenvs/
  rm -rf $HOME/virtualenvs/*
  echo "$ARROW Creating default virtualenv"
  virtualenv $HOME/virtualenvs/default
fi

echo "$CMARK Default virtualenv present"

# Always activate default virtualenv, since we install everything via pip.
source $HOME/virtualenvs/default/bin/activate

# Install python packages
for p in $(cat $HOME/dotfiles/scripts/python-packages); do
  # Deal with direct from GitHub installs
  if (echo $p | grep -q github.com); then
    package_name=`echo $p | rev | cut -d/ -f1 | rev | cut -d. -f1`
  else
    package_name=$p
  fi
  if ! pip show $package_name > /dev/null; then
    echo "  $ARROW installing package $package_name"
    pip install -q -U $p
  fi
done
echo "$CMARK All python packages installed"
