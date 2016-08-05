#!/bin/bash
echo "Downloading latest rclone"
TEMP_DIR=$(mktemp -d)
pushd "$TEMP_DIR" > /dev/null
wget -q -O /tmp/rclone.zip "http://downloads.rclone.org/rclone-current-linux-amd64.zip"
unzip -j /tmp/rclone.zip
chmod +x rclone
mv rclone "$HOME/.local/bin/."
popd > /dev/null
rm -rf "$TEMP_DIR"
echo "Installation complete"
