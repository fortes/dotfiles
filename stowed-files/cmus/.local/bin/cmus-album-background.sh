#!/bin/bash
TMP_ART_PATH="/tmp/album-bg-blurred.png"

CMUS_STATUS=$(cmus-remote -Q 2>/dev/null)
if [[ $? != 0 ]]; then
  echo 'cmus not running, exiting'
  hsetroot -solid "#222222"
  rm "$TMP_ART_PATH"
  exit 1
fi

if grep -iq "^status stopped" <<< "$CMUS_STATUS"; then
  echo 'cmus stopped, exiting'
  hsetroot -solid "#222222"
  rm "$TMP_ART_PATH"
  exit 1
fi

ALBUM_DIRPATH=$(grep -i "^file" <<< "$CMUS_STATUS" | cut -f2- -d' ' | xargs -0 dirname)
ART_PATH=$(ls "$ALBUM_DIRPATH"/folder.* 2> /dev/null | head -n 1)

if [[ $? != 0 ]] || [[ -z "$ART_PATH" ]]; then
  echo 'album art file not found, exiting'
  hsetroot -solid "#222222"
  rm "$TMP_ART_PATH"
  exit 1
fi

RESOLUTION=$(xrandr | grep \* | awk '{print $1}')
convert "$ART_PATH" -scale 20% -scale "$RESOLUTION"\! \
  -modulate 100,20,100 -fill black -colorize 20% \
  "$TMP_ART_PATH"

echo "setting background to $TMP_ART_PATH"
feh --bg-fill "$TMP_ART_PATH"
