#!/bin/bash

# Converts a video file to GIF
# Cribbed from `http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html`

# strict mode
set -euo pipefail
IFS=$'\n\t'

VIDEO_FILE=$1
PALETTE_FILE_PATH=$(mktemp -u -t palette-XXXX.png)
WIDTH=1024

FFMPEG_FILTERS="fps=15,scale=$WIDTH:-1:flags=lanczos"
echo "$VIDEO_FILE → $VIDEO_FILE.gif"
# Generate palette
ffmpeg -v warning -i "file:$VIDEO_FILE" \
  -vf "$FFMPEG_FILTERS,palettegen" \
  -y "$PALETTE_FILE_PATH"

ffmpeg -v warning \
  -i "file:$VIDEO_FILE" \
  -i "$PALETTE_FILE_PATH" \
  -lavfi "$FFMPEG_FILTERS [x]; [x][1:v] paletteuse" -y "file:$VIDEO_FILE.gif"

rm "$PALETTE_FILE_PATH"
