# Install
echo 'Installing (requires sudo)'
sudo -E apt-get install samba
# Set password
echo "Setting passwd"
sudo -E smbpasswd -a fortes
# Copy original conf
cp /etc/samba/smb.conf ~/smb.conf.backup
echo "Now edit /etc/samba/smb.conf"

