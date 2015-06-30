#!/bin/bash
MAX_TITLE_WIDTH=70

if cmus-remote -Q > /dev/null 2> /dev/null; then
  STATUS+=$(cmus-remote -Q | grep status | head -n 1 | cut -d' ' -f2-)
  ARTIST+=$(cmus-remote -Q | grep 'tag artist' | head -n 1 | cut -d' ' -f3-)
  TITLE=$(cmus-remote -Q | grep 'tag title' | cut -d' ' -f3-)
  if [ -n "$TITLE" ]; then
    OUTPUT="$ARTIST - $TITLE"

    # Only show the song title if we are over 50 characters
    if [ "${#OUTPUT}" -ge $MAX_TITLE_WIDTH ]; then
      OUTPUT=$TITLE
    fi

    if [ "$STATUS" = "playing" ]; then
      OUTPUT="[▶ $OUTPUT]"
    else
      OUTPUT="[❚❚$OUTPUT]"
    fi
  else
    OUTPUT=''
  fi
fi
echo $OUTPUT
