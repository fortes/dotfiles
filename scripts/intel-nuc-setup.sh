# Get better audio drivers
if [ ! -f /etc/apt/sources.list.d/ubuntu-audio-dev-alsa-daily-trusty.list ]; then
  echo "Adding alsa-daily apt source (requires sudo)"
  sudo add-apt-repository ppa:ubuntu-audio-dev/alsa-daily
  sudo -E apt-get -qfuy install oem-audio-hda-daily-dkms
fi

