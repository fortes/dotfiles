#!/usr/bin/env bash
# Install yarn
#
# Usage: setup_yarn

set -euo pipefail
IFS=$'\n\t'
export DEBIAN_FRONTEND=noninteractive

main() {
  declare -r yarn_sources_list="/etc/apt/sources.list.d/yarn.list"
  declare -r yarn_key_url="https://dl.yarnpkg.com/debian/pubkey.gpg"
  declare -r yarn_key_path="/etc/apt/trusted.gpg.d/yarn.gpg"

  if [ ! -f "$yarn_sources_list" ]; then
    echo "Adding Yarn GPG key (requires sudo)"
    curl -sS "$yarn_key_url" | \
      sudo tee "$yarn_key_path" > /dev/null

    echo "Yarn sources list missing, adding (requires sudo)"
    echo "deb [arch=amd64 signed-by=${yarn_key_path}] https://dl.yarnpkg.com/debian stable main" \
      | sudo tee "$yarn_sources_list"

    echo "Yarn sources added, updating packages"
    sudo -E apt-get update -qq
  fi

  echo "Installing yarn package (requires sudo)"
  sudo -E apt-get install -qq --assume-yes \
    --fix-broken --no-install-recommends yarn
}

main
