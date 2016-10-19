#!/bin/bash
#
# Ghetto display of battery status for use in tmux 

if ! command -v upower > /dev/null; then
  >&2 echo "Must install upower"
  exit 1
fi

BATTERY=$(upower -e | grep battery)
if [ -z "$BATTERY" ]; then
  # No battery means likely desktop, output nothing since we don't care about
  # power state that can never change.
  exit 0
fi

BATTERY_INFO=$(upower -i "$BATTERY")
BATTERY_ICON="⚡ "
if echo "$BATTERY_INFO" | grep -i state | grep -qi discharging; then
  BATTERY_ICON=""
fi
BATTERY_PERCENTAGE=$(echo "$BATTERY_INFO" | grep -i percentage | awk '{print $2}')
echo "[$BATTERY_ICON$BATTERY_PERCENTAGE]"
