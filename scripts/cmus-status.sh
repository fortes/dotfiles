#!/bin/bash

# Report to last.fm
# Run last-cmus in background so we don't delay tmux status message
python ~/dotfiles/scripts/last-cmus.py "$@" &

# Send message to tmux (disabled since already in status bar)
#if [ -n $TMUX ]; then
if false; then
  title=""
  album=""
  artist=""
  status="stopped"

  # Parse out the cmus arguments, based off of:
  # https://github.com/cmus/cmus/wiki/status_display_short_text.sh
  #
  # Output looks like:
  # status playing file /path/to/file.mp3 artist ArtistName ablum AlbumName ...
  while [ "$1" != "" ]; do
    case "$1" in
      title)
        title="$2"
      ;;
      album)
        album="$2"
      ;;
      artist)
        artist="$2"
      ;;
      status)
        status="$2"
      ;;
      *)
      ;;
    esac
    shift
    shift
  done

  if [ "$status" = "stopped" ]; then
    message="cmus stopped"
  elif [ "$status" = "paused" ]; then
    message="cmus paused"
  elif [ -n "$title" ] && [ -n "$artist" ]; then
    # Make the message display long enough to be seen
    tmux set-opt display-time 3000
    message="$artist - $title"
  fi

  if [ -n "$message" ]; then
    tmux display-message "♬ $message"
    # Reset display-time
    tmux set-opt -u display-time
  fi
fi

# Manually refresh the status bar
tmux refresh-client -S
