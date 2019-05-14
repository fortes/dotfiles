#!/usr/bin/env bash
set -euf -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

main() {
  declare -r unstable_sources_list="/etc/apt/sources.list.d/debian-unstable.list"

  if [ ! -f "$unstable_sources_list" ]; then
    echo "$XMARK Debian unstable sources list missing"

    echo "  $ARROW Adding unstable to sources (requires sudo)"
    echo "deb http://deb.debian.org/debian/ unstable main" \
      | sudo tee "$unstable_sources_list"
    echo "$CMARK Unstable sources added, updating (requires sudo)"
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq

    echo "  $ARROW Decreasing priority of unstable packages (requires sudo)"
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' \
      | sudo tee /etc/apt/preferences.d/limit-unstable
  fi
}

main
