#!/bin/bash
set -ef -o pipefail
source "$HOME/dotfiles/scripts/helpers.sh"

if [[ "$IS_CROUTON" == 1 ]]; then
  echo "$XMARK Crouton does not support Docker"
  exit 1
fi

DOCKER_SOURCES_FILE=/etc/apt/sources.list.d/docker.list
if [ ! -f $DOCKER_SOURCES_FILE ]; then
  echo "$XMARK Docker not in sources.list"
  echo "  $ARROW Adding docker to in sources.list (requires sudo)"
  sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo ${DISTRO,,}-${VERSION} main" | \
    sudo tee "$DOCKER_SOURCES_FILE"
  sudo apt-get update -qq
fi
echo "$CMARK Docker in sources.list"

echo "$ARROW Installing Docker (requires sudo)"
installAptPackagesIfMissing docker-engine

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
