#!/bin/bash

# Report to last.fm
# Run last-cmus in background so we don't delay tmux status message
if [[ -n $LAST_FM_USERNAME ]]; then
  python2 ~/dotfiles/scripts/last-cmus.py "$@" > /tmp/cmus-status.txt 2>&1 &
fi

# Update the tmux status bar, if running in tmux
if [[ -n $TMUX ]]; then
  tmux refresh-client -S
fi
