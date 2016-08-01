#!/bin/bash
set -euf -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v apt-get > /dev/null; then
  echo "$XMARK Setup only supported on Ubuntu systems for now"
  exit 1
fi

if ! command -v mergerfs > /dev/null; then
  INSTALL_DIR=/tmp/mergerfs
  LATEST_URL="https://github.com/trapexit/mergerfs/releases/download/2.14.0/mergerfs_2.14.0.debian-jessie_amd64.deb"

  echo "$XMARK mergerfs not installed"
  echo "$ARROW Downloading latest mergerfs deb ..."
  mkdir -p "$INSTALL_DIR"
  pushd "$INSTALL_DIR" > /dev/null
  wget -q "$LATEST_URL" -O mergerfs.deb
  echo "  $ARROW Installing mergerfs deb (requires sudo)"
  sudo dpkg -i mergerfs.deb

  # Clean up
  popd > /dev/null
  rm -rf "$INSTALL_DIR"
fi

echo "$CMARK mergerfs installed"
