#!/bin/bash

IS_CROUTON=0
IS_HIDPI=0
if command -v croutonversion > /dev/null; then
  IS_CROUTON=1
  # Chromebook Pixel 2
  if croutonversion | grep -q samus; then
    IS_HIDPI=1
  fi
fi

# Caps lock sucks
setxkbmap -layout us -option "ctrl:nocaps,altwin:left_meta_win" && \
  # Re-map chromebook search key to control
  test "$IS_CROUTON" = 1 && xmodmap "$HOME/.Xmodmap.crouton" || true && \
  # So many pixels!
  test "$IS_HIDPI" = 1 && xrandr --dpi 144 || true && \
  # More DPI
  test "$IS_HIDPI" = 1 && xrdb -merge ~/.Xresources || true && \
  # Begin!
  exec i3
