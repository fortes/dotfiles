set -eo pipefail

if ! which apt-get 2> /dev/null; then
  echo "Currently only works on Ubuntu systems"
  exit 1
fi

# Make sure not to get stuck on any prompts
export DEBIAN_FRONTEND=noninteractive

if dpkg -s ubuntu-desktop > /dev/null 2> /dev/null; then
  # Can't use gnome in Ubuntu 14.04 because it doesn't work without hw
  # acceleration, so we install xfce which we will then use for our session
  sudo -E apt-get install -qfuy xfce4
elif ! dpkg -s xubuntu-desktop > /dev/null 2> /dev/null; then
  # With no GUI yet, let's just use Xubuntu, which is relatively lightweight
  echo "Installing xubuntu-desktop (requires sudo and takes a long time)"
  sudo -E apt-get update -q
  sudo -E apt-get install -qfuy xubuntu-desktop
fi

if ! dpkg -s vnc4server > /dev/null 2> /dev/null; then
  echo "Installing vnc4server (requires sudo)"
  sudo -E apt-get install -qfuy vnc4server
fi

if ! dpkg -s xrdp > /dev/null 2> /dev/null; then
  echo "Installing xrdp (requires sudo)"
  sudo -E apt-get install -qfuy xrdp
fi

if [ ! -f $HOME/.xsession ]; then
  echo "Creating .xsession"
  echo "xfce4-session" > $HOME/.xsession
fi

if [ "$USER" == "ubuntu" ]; then
  echo "Must have a password set for user before being able to connect"
  sudo passwd $USER
fi

echo "If you're on the same local network, you can now connect via RDP"
echo ""
echo "For remote access, create an SSH tunnel:"
echo "  ssh -f -N -o 'Compression=no' -L 3389:localhost:3389 HOSTNAME"
echo "Then connect RDP to localhost:3389"
echo ""
echo "Make sure to disable screensaver. May also need to change theme / icons"
