#!/bin/bash
set -eo pipefail

# Make sure to load OS/Distro/etc variables
source "$HOME/.profile.local"
source "$HOME/dotfiles/scripts/helpers.sh"

if [ "$OS" != "Linux" ]; then
  echo "$XMARK Non-Linux setup not supported"
  return 1
fi

if ! commandExists apt-get; then
  echo "$XMARK Non-apt setup not supported"
  return 1
fi

# Make sure not to get stuck on any prompts
export DEBIAN_FRONTEND=noninteractive

if [ "$IS_EC2" != 1 ] && [ "$IS_DOCKER" != 1 ]; then
  ("$HOME/dotfiles/scripts/debian-keyboard.sh" || true)
fi

PACKAGES=$(xargs < "$HOME/dotfiles/scripts/apt-packages-headless")
if [ "$IS_HEADLESS" != 1 ]; then
  # GUI-only packages
  PACKAGES="$PACKAGES $(xargs < "$HOME/dotfiles/scripts/apt-packages")"
fi

# Map git to correct remote
pushd "$HOME/dotfiles" > /dev/null
if ! git remote -v | grep -q -F "git@github.com"; then
  echo "$XMARK Dotfiles repo git remote not set"
  git remote set-url origin git@github.com:fortes/dotfiles.git
fi
echo "$CMARK Dotfiles repo git remote set"

popd > /dev/null

installAptPackagesIfMissing "$PACKAGES"
echo "$CMARK apt packages installed"

if [ "$IS_HEADLESS" != 1 ]; then
  echo "$ARROW Setting default browser to chromium"
  sudo update-alternatives --set x-www-browser "$(which chromium)"
  echo "$ARROW Setting default terminal to kitty"
  sudo update-alternatives --set x-terminal-emulator "$(which kitty)"
fi

# Link dotfiles
echo "$ARROW Linking dotfiles"
# Remove default .bashrc and .profile on first run
if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
  echo "$ARROW Removing default .bashrc"
  mv "$HOME/.bashrc" "$HOME/bashrc.original"
fi
if [[ -f "$HOME/.profile" && ! -L "$HOME/.profile" ]]; then
  echo "$ARROW Removing default .profile"
  mv "$HOME/.profile" "$HOME/profile.original"
fi

("$HOME/dotfiles/scripts/stow.sh")

# Update source paths, etc
source ~/.profile
source ~/.bashrc

("$HOME/dotfiles/scripts/increase-max-watchers.sh")
("$HOME/dotfiles/scripts/cargo-setup.sh")
("$HOME/dotfiles/scripts/python-setup.sh")
("$HOME/dotfiles/scripts/node-setup.sh")
("$HOME/dotfiles/scripts/nvim-setup.sh")
