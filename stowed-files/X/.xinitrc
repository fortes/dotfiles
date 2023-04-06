#!/bin/bash

source_if_exists /etc/X11/xinit/xinitrc

dbus-update-activation-environment --systemd --all

xrdb -I"${HOME}" -merge ~/.Xresources && \
  # Begin!
  exec dbus-launch --sh-syntax --exit-with-session i3
