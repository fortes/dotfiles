set -euo pipefail

if ! hash apt-get 2> /dev/null; then
  echo "Currently only works on Ubuntu systems"
  exit 1
fi

# Make sure not to get stuck on any prompts
DEBIAN_FRONTEND=noninteractive

FILEBOT_DEB_URL='http://downloads.sourceforge.net/project/filebot/filebot/FileBot_4.2/filebot_4.2_amd64.deb?r=&ts=1407563882&use_mirror=iweb'

if ! dpkg -s filebot > /dev/null; then
  pushd /tmp > /dev/null
  echo "Downloading & Installing Filebot .deb (requires sudo)"
  wget $FILEBOT_DEB_URL
  sudo -E dpkg -i --force-confdef --force-confnew `basename $FILEBOT_DEB_URL`
  rm `basename $FILEBOT_DEB_URL`
  popd
fi
echo 'Filebot installed'
