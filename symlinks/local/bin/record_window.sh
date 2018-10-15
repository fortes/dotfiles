#!/bin/bash
#
# Records current window

# strict mode
set -euo pipefail
IFS=$'\n\t '

# Acts as `stdin` for `ffmpeg` process
SCREEN_CAP_INPUT_FILE=/tmp/i3-screencap-input
if [ -f "$SCREEN_CAP_INPUT_FILE" ]; then
  # Quit if already running
  echo 'q' > "$SCREEN_CAP_INPUT_FILE"
  rm "$SCREEN_CAP_INPUT_FILE"
  notify 'Window recording saved!'
  exit
fi

FILENAME="$HOME/Downloads/screencast-$(date +%F-%T).mp4"

SCREEN_COORDS=$(slop -f "%x %y %w %h" --highlight --color=0.25,0.5,1,0.25) || exit 1
read -r X Y W H < <(echo $SCREEN_COORDS)

touch "$SCREEN_CAP_INPUT_FILE"
< "$SCREEN_CAP_INPUT_FILE" ffmpeg -framerate 25 \
  -f x11grab \
  -s "$W"x"$H" \
  -i :0.0+"$X","$Y" \
  "$FILENAME" #\
  # > /dev/null 2> /tmp/i3-screencap.log

if command -v video_to_gif.sh > /dev/null; then
  video_to_gif.sh "$FILENAME"
fi
