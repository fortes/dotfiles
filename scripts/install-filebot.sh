#!/bin/bash
set -euf
source "$HOME/dotfiles/scripts/helpers.sh"

if ! command -v apt-get 2> /dev/null; then
  echo "Currently only works on Ubuntu systems"
  exit 1
fi

installAptPackageIfMissing openjdk-8-jre

FILEBOT_DEB_URL='http://downloads.sourceforge.net/project/filebot/filebot/FileBot_4.6/filebot_4.6_amd64.deb'

if ! dpkg -s filebot > /dev/null; then
  pushd /tmp > /dev/null
  echo "Downloading & Installing Filebot .deb (requires sudo)"
  wget $FILEBOT_DEB_URL
  # Make sure not to get stuck on any prompts
  DEBIAN_FRONTEND=noninteractive sudo -E dpkg -i --force-confdef --force-confnew `basename $FILEBOT_DEB_URL`
  rm `basename $FILEBOT_DEB_URL`
  popd
fi
echo 'Filebot installed'
