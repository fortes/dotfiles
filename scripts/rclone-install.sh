#!/bin/bash
echo "Downloading latest rclone"
TEMP_DIR=$(mktemp -d /tmp/rcloneXXX)
pushd "$TEMP_DIR" > /dev/null
wget -q -O "$TEMP_DIR/rclone.zip" "http://downloads.rclone.org/rclone-current-linux-amd64.zip"
unzip -j "$TEMP_DIR/rclone.zip"
chmod +x rclone
mkdir -p "$HOME/.local/bin"
mv rclone "$HOME/.local/bin/."
popd > /dev/null
rm -rf "$TEMP_DIR"
echo "Installation complete"
