# Get better audio drivers
if [ ! -f /etc/apt/sources.list.d/ubuntu-audio-dev-alsa-daily-trusty.list ]; then
  echo "Adding alsa-daily apt source (requires sudo)"
  sudo add-apt-repository -y ppa:ubuntu-audio-dev/alsa-daily
  sudo apt-get -q update
  sudo -E apt-get -qqfuy install oem-audio-hda-daily-dkms

  echo "New Audio Drivers Added. You need to reboot"
fi
