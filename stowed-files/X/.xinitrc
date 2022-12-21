#!/bin/bash

source_if_exists /etc/X11/xinit/xinitrc

# Caps lock sucks
setxkbmap -layout us -option "ctrl:nocaps,altwin:left_meta_win"

# Reasonable key repeat. First number is ms delay, second is repetitions per s
xset r rate 250 45

xrdb -I"${HOME}" -merge ~/.Xresources && \
  # Begin!
  exec dbus-launch --sh-syntax --exit-with-session i3
