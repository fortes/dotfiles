# Install
echo 'Installing (requires sudo)'
sudo apt-get install samba
# Set password
echo "Setting passwd"
sudo smbpasswd -a fortes
# Copy original conf
cp /etc/samba/smb.conf ~/smb.conf.backup
echo "Now edit /etc/samba/smb.conf"

