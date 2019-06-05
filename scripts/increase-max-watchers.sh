#!/usr/bin/env bash

main() {
  declare -r conf_file_path="/etc/sysctl.d/20-increase-max-watchers.conf"
  declare -r max_watches="524288"

  if [ ! -f  "$conf_file_path" ]; then
    echo "Increasing max watchers (requires sudo)"
    echo "fs.inotify.max_user_watches=$max_watches" | \
      sudo tee -a "$conf_file_path" && sudo sysctl -p
    echo "Max watchers set to $max_watches"
  fi
}

main
