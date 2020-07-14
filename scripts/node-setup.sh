#!/bin/bash
set -ef -o pipefail
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

if ! update-alternatives --get-selections | grep -q "^yarn"; then
  echo "$ARROW Updating alternative yarnpkg to yarn (requires sudo)"
  sudo update-alternatives --install /usr/bin/yarn yarn /usr/bin/yarnpkg 10
fi
echo "$CMARK Yarn system alternatives set"

NPM_BASH_COMPLETION_PATH="$HOME/.local/completions.d/npm"
if [ ! -f "$NPM_BASH_COMPLETION_PATH" ]; then
  mkdir -p "$(dirname "$NPM_BASH_COMPLETION_PATH")"
  npm completion > "$NPM_BASH_COMPLETION_PATH"
fi

# Yarn is fast enough that we just install everything at once
echo "$ARROW Installing global node packages"
< "$HOME/dotfiles/scripts/node-packages" xargs yarnpkg global add --ignore-engines

echo "$CMARK All node packages installed"
