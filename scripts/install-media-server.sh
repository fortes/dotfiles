set -euo pipefail

if ! hash apt-get 2> /dev/null; then
  echo "Currently only works on Ubuntu systems"
  exit 1
fi

PLEX_DEB_URL="http://downloads.plexapp.com/plex-media-server/0.9.9.12.504-3e7f93c/plexmediaserver_0.9.9.12.504-3e7f93c_amd64.deb"

APT_PREREQUISITES=(avahi-utils)

# Install pre-requisites
for p in "${APT_PREREQUISITES[0]}"; do
  if ! dpkg -s $p > /dev/null; then
    echo "Installing missing package $p (requires sudo)"
    sudo -E apt-get install -q -y $p
  fi
done

if ! dpkg -s plexmediaserver > /dev/null; then
  pushd /tmp > /dev/null
  echo "Downloading & Installing Plex Media Server .deb (requires sudo)"
  wget $PLEX_DEB_URL
  sudo -E dpkg -i `basename $PLEX_DEB_URL`
  rm `basename $PLEX_DEB_URL`
  popd
fi

if [[ -z "$(status plexmediaserver | grep start)" ]]; then
  echo "Starting Plex Media Server Service (requires sudo)"
  sudo -E service plexmediaserver start
  echo ""
fi

echo "------------------------------------------------------"
echo "Configure Plex via http://localhost:32400/web"
echo ""
echo "If not on same network, open SSH tunnel:"
echo "  ssh ip.address.of.server -L 8888:localhost:32400"
echo "Then open http://localhost:8888/web on your computer"
echo "------------------------------------------------------"

# This is for the media center UI (not fully implemented yet)
# Add plex into apt sources list
if [ ! -f /etc/apt/sources.list.d/plexapp-plexht-trusty.list ]; then
  echo "Adding Plex apt source (requires sudo)"
  sudo -E add-apt-repository -y ppa:plexapp/plexht
fi
# Remote / HDMI integration
if [ ! -f /etc/apt/sources.list.d/pulse-eight-libcec-trusty.list ]; then
  echo "Adding libcec apt source (requires sudo)"
  sudo -E add-apt-repository -y ppa:pulse-eight/libcec
fi

echo "Installing Plex Home Theatre (requires sudo)"
sudo -E apt-get install plexhometheater
