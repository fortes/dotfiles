set -euo pipefail

if ! hash apt-get 2> /dev/null; then
  echo "Currently only works on Ubuntu systems"
  exit 1
fi

# Make sure not to get stuck on any prompts
DEBIAN_FRONTEND=noninteractive

# Keep things silent and without prompts
APT_OPTIONS="-q -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""

# Install
echo 'Installing (requires sudo)'
sudo -E apt-get $APT_OPTIONS install samba
# Set password
echo "Setting passwd"
sudo -E smbpasswd -a fortes
# Copy original conf
cp /etc/samba/smb.conf ~/smb.conf.backup
echo "Now edit /etc/samba/smb.conf"

