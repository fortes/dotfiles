#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

# Install python packages
for package in $(cat $HOME/dotfiles/scripts/python-packages); do
  if [[ -z "$(pip3 show "$package")" ]]; then
    echo "  $ARROW installing package $package"
    pip3 install -q -U --user "$package"
  fi
done
echo "$CMARK All python packages installed"
