#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

# Install python packages, but make sure pip and setuptools are latest first
echo "$ARROW Installing/upgrading pip packages"
pip3 install --user --quiet --upgrade pip setuptools
< "$HOME/dotfiles/scripts/python-packages" xargs pip install --user --quiet --upgrade

echo "$CMARK All python packages installed"
echo "$CMARK Python setup complete"
