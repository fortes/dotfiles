#!/bin/bash
set -ef -o pipefail
# shellcheck source=./helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if [[ "$IS_CROUTON" == 1 ]]; then
  echo "$XMARK Crouton does not support Docker"
  exit 1
fi

DOCKER_SOURCES_FILE=/etc/apt/sources.list.d/docker.list
if [ ! -f "$DOCKER_SOURCES_FILE" ]; then
  echo "$XMARK Docker not in sources.list"
  echo "  $ARROW Adding docker to in sources.list (requires sudo)"
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  echo "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) stable" | sudo tee "$DOCKER_SOURCES_FILE"
  sudo apt-get update -qq
fi
echo "$CMARK Docker in sources.list"

echo "$ARROW Installing Docker and dependencies (requires sudo)"
installAptPackagesIfMissing apt-transport-https ca-certificates curl gnupg2 \
  software-properties-common docker-ce

if [ ! -f "/etc/sudoers.d/$USER-docker" ]; then
  echo "$ARROW Allowing $USER to run docker without sudo prompt (requires sudo)"
  echo "$(whoami)  ALL=(ALL) NOPASSWD: /usr/bin/docker" |
    sudo tee &> /dev/null "/etc/sudoers.d/$USER-docker"
fi
echo "$CMARK Sudo-less docker setup"

# Unclear if this part is still needed. Under default config, Docker will go
# around ufw using iptables.
# TODO: Override docker defaults and make sure to use ufw for all docker ports
# echo "$ARROW Checking if ufw is running (may require sudo)"
# if command -v ufw > /dev/null && sudo ufw status | grep -qw active; then
#   FWD_POLICY_STRING=(DEFAULT_FORWARD_POLICY="ACCEPT")
#   if ! grep -qw "${FWD_POLICY_STRING[@]}"; then
#     echo "$ARROW Setting" "${FWD_POLICY_STRING[@]}" "(requires sudo)"
#     sudo sed -i.bak \
#       's/DEFAULT_FORWARD_POLICY="[a-zA-Z]"/'.DEFAULT_FORWARD_POLICY.'/g' \
#       /etc/default/ufw
#     sudo rm /etc/default/ufw.bak
#   fi

#   echo "$ARROW Allowing incoming connections on Docker port (requires sudo)"
#   sudo ufw allow 2375/tcp
#   echo "$CMARK ufw rules for docker setup"
# fi

echo "$CMARK Docker installed and setup"
