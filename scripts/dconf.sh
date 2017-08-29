#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

# Dump via: `dconf dump / > $DCONF_SETTINGS_FILE`

DCONF_SETTINGS_FILE="$HOME/dotfiles/dconf-dump"
echo "$ARROW Loading dconf settings"
dconf load / < "$DCONF_SETTINGS_FILE"
echo "$CMARK Dconf settings loaded!"
