#!/bin/bash

if [ -f /etc/X11/xinit/xinitrc ]; then
  . /etc/X11/xinit/xinitrc
fi

# Caps lock sucks
setxkbmap -layout us -option "ctrl:nocaps,altwin:left_meta_win" && \
  # Re-map chromebook search key to control
  test "$IS_CROUTON" = 1 && xmodmap "$HOME/.Xmodmap.crouton" || true && \
  # So many pixels!
  test "$IS_HIDPI" = 1 && xrandr --dpi 144 || true && \
  # Begin!
  exec i3
