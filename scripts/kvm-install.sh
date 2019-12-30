#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

echo "$ARROW Installing KVM stuff (requires sudo)"
sudo apt-get install --no-install-recommends -qqfuy \
  qemu-kvm libvirt-clients libvirt-daemon-system virtinst dnsmasq-base

# Can hit all sorts of polkit errors if you don't do this
echo "$ARROW Add user to libvirt group (requires sudo)"
sudo usermod -a -G libvirt "$(whoami)"

# TODO: Make sure network autostarts
# virsh net-autostart default

echo "$CMARK KVM installed"
