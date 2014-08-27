set -eo pipefail

if ! hash apt-get 2> /dev/null; then
  echo "Currently only works on Ubuntu systems"
  exit 1
fi

PLEX_CONNECT_DIR=/usr/local/plexconnect
PLEX_CONNECT_LOG_DIR=/var/log/plexconnect
ASSETS_DIR=$PLEX_CONNECT_DIR/assets/certificates

if ! grep media /etc/group > /dev/null; then
  echo "Creating media group"
  sudo groupadd media
fi

if ! id plexconnect > /dev/null; then
  echo "Creating PlexConnect user"
  sudo useradd -r plexconnect -G media
fi

if [ ! -d $PLEX_CONNECT_DIR ]; then
  sudo -E mkdir -p $PLEX_CONNECT_DIR
  sudo -E chown -R $USER $PLEX_CONNECT_DIR
  echo "Fetching PlexConnect source"
  git clone https://github.com/iBaa/PlexConnect.git $PLEX_CONNECT_DIR > /dev/null
  pushd $PLEX_CONNECT_DIR
  echo "Generating certificates"
  openssl req -new -nodes -newkey rsa:2048 \
              -out $ASSETS_DIR/trailers.pem \
              -keyout $ASSETS_DIR/trailers.key -x509 -days 7300 \
              -subj "/C=US/CN=trailers.apple.com"
  openssl x509 -in $ASSETS_DIR/trailers.pem -outform der \
              -out $ASSETS_DIR/trailers.cer && \
              cat $ASSETS_DIR/trailers.key >> $ASSETS_DIR/trailers.pem
  popd

  echo "Creating Settings.cfg"
  cat << EOF > $PLEX_CONNECT_DIR/Settings.cfg
[PlexConnect]
port_dnsserver = 10053
port_webserver = 10080
port_ssl = 10443
logpath = $PLEX_CONNECT_LOG_DIR
EOF

  # Make sure service can write around there
  sudo -E chown -R plexconnect $PLEX_CONNECT_DIR
fi

if [ ! -d $PLEX_CONNECT_LOG_DIR ]; then
  echo "Creating $PLEX_CONNECT_LOG_DIR"
  sudo -E mkdir -p $PLEX_CONNECT_LOG_DIR
  sudo -E chown -R plexconnect $PLEX_CONNECT_LOG_DIR
fi

if [ ! -f /etc/init.d/plexconnect ]; then
  echo "Copying PlexConnect boot script"
  sudo -E cp $HOME/dotfiles/scripts/support-files/plex-connect-init.d /etc/init.d/plexconnect
  sudo -E chmod a+x /etc/init.d/plexconnect
fi

echo "Starting PlexConnect Service"
sudo service plexconnect start

echo "----------------------------------------------------------------"
echo "Now you must setup firewall forwarding rules"
echo ""
echo "Then setup Apple TV: https://github.com/iBaa/PlexConnect/wiki"
echo "----------------------------------------------------------------"
