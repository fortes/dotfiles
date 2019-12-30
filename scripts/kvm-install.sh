#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

echo "$ARROW Installing KVM stuff (requires sudo)"
sudo apt-get install --no-install-recommends -qqfuy \
  qemu-kvm libvirt-clients libvirt-daemon-system virtinst

echo "$CMARK KVM installed"
