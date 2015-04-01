#!/bin/bash
if cmus-remote -Q > /dev/null 2> /dev/null; then
  STATUS+=$(cmus-remote -Q | ack status | head -n 1 | cut -d' ' -f2-)
  ARTIST+=$(cmus-remote -Q | ack 'tag artist' | head -n 1 | cut -d' ' -f3-)
  TITLE=$(cmus-remote -Q | ack 'tag title' | cut -d' ' -f3-)
  OUTPUT="$ARTIST - $TITLE"
  # Only show the song title if we are over 50 characters
  if [ "${#OUTPUT}" -ge 50 ]; then
    OUTPUT=$TITLE
  fi
  if [ "$STATUS" = "playing" ]; then
    OUTPUT="[▶ $OUTPUT]"
  else
    OUTPUT="[❚❚$OUTPUT]"
  fi
fi
echo $OUTPUT
