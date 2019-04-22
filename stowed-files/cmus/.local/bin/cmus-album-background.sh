#!/bin/bash
PREVIOUS_FOLDER_PATH="/tmp/album-folder-path.txt"
TMP_ART_PATH="/tmp/album-bg-blurred.png"
DEFAULT_BG="#222222"

CMUS_STATUS=$(cmus-remote -Q 2>/dev/null)
if [[ $? != 0 ]]; then
  echo 'cmus not running, exiting'
  hsetroot -solid "$DEFAULT_BG"
  rm "$TMP_ART_PATH" "$PREVIOUS_FOLDER_PATH"
  exit 1
fi

if grep -iq "^status stopped" <<< "$CMUS_STATUS"; then
  echo 'cmus stopped, exiting'
  hsetroot -solid "$DEFAULT_BG"
  rm "$TMP_ART_PATH" "$PREVIOUS_FOLDER_PATH"
  exit 1
fi

ALBUM_DIRPATH=$(grep -i "^file" <<< "$CMUS_STATUS" | cut -f2- -d' ' | xargs -0 dirname)
PREVIOUS_DIRPATH=$(cat "$PREVIOUS_FOLDER_PATH" 2>/dev/null || true)

if [[ "$ALBUM_DIRPATH" != "$PREVIOUS_DIRPATH" ]]; then
  ART_PATH=$(ls "$ALBUM_DIRPATH"/folder.* 2> /dev/null | head -n 1)

  if [[ $? != 0 ]] || [[ -z "$ART_PATH" ]]; then
    echo 'album art file not found, exiting'
    hsetroot -solid "$DEFAULT_BG"
    rm "$TMP_ART_PATH"
    exit 1
  fi

  RESOLUTION=$(xrandr | grep \* | awk '{print $1}')
  convert "$ART_PATH" -background "$DEFAULT_BG" \
    -scale "$RESOLUTION"\^ -paint 6 \
    -modulate 100,20,100 -fill "$DEFAULT_BG" -colorize 20% \
    "$TMP_ART_PATH"

  echo "setting background to $TMP_ART_PATH"
  feh --bg-center "$TMP_ART_PATH"
else
  echo 'already set to current album'
fi

echo "$ALBUM_DIRPATH" > /tmp/album-folder-path.txt
