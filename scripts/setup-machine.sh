#!/bin/bash
set -eo pipefail

# Make sure to load OS/Distro/etc variables
source "$HOME/.profile.local"
source "$HOME/dotfiles/scripts/helpers.sh"

if [ "$DISTRO" = "Chromebook" ]; then
  echo "$XMARK Chromebook setup not complete yet"
  return 1
elif [ "$OS" == "Linux" ]; then
  if ! command -v apt-get > /dev/null; then
    echo "$XMARK Non-apt setup not supported"
    return 1
  fi

  # Make sure not to get stuck on any prompts
  export DEBIAN_FRONTEND=noninteractive
fi

if [ "$IS_EC2" != 1 ] && [ "$IS_DOCKER" != 1 ]; then
  ("$HOME/dotfiles/scripts/debian-keyboard.sh" || true)
fi

if [ "$IS_CROUTON" == 1 ]; then
  "$HOME/dotfiles/scripts/locale-gen.sh"
  # Can't run docker on crouton :(
  FAKE_DOCKER_PATH="/usr/bin/docker"
  if [ ! -x "$FAKE_DOCKER_PATH" ]; then
    echo "$ARROW Creating fake docker executable (requires sudo)"
    sudo tee "$FAKE_DOCKER_PATH" > /dev/null <<FAKE_DOCKER
#!/bin/bash
>&2 echo 'Docker does not run on crouton'
exit 1
FAKE_DOCKER
    sudo chmod +x "$FAKE_DOCKER_PATH"
  fi
  echo "$CMARK Fake docker bin installed for crouton"
fi

PACKAGES=$(xargs < "$HOME/dotfiles/scripts/apt-packages-headless")
if [ "$IS_HEADLESS" != 1 ]; then
  # GUI-only packages
  PACKAGES="$PACKAGES $(xargs < "$HOME/dotfiles/scripts/apt-packages")"
fi

# Map git to correct remote
pushd "$HOME/dotfiles" > /dev/null
if ! git remote -v | grep -q -F "git@github.com"; then
  echo "$XMARK Dotfiles repo git remote not set"
  git remote set-url origin git@github.com:fortes/dotfiles.git
fi
echo "$CMARK Dotfiles repo git remote set"

popd > /dev/null

installAptPackagesIfMissing "$PACKAGES"
echo "$CMARK apt packages installed"

if [ "$IS_HEADLESS" != 1 ]; then
  # Set default browser
  echo "$ARROW Setting default browser to chromium"
  sudo update-alternatives --set x-www-browser "$(which chromium)"
fi

# Link missing dotfiles
("$HOME/dotfiles/scripts/link-dotfiles.sh" -f)

# Update source paths, etc
source ~/.profile
source ~/.bashrc

("$HOME/dotfiles/scripts/python-setup.sh")
("$HOME/dotfiles/scripts/node-setup.sh")
("$HOME/dotfiles/scripts/fzf-setup.sh")
("$HOME/dotfiles/scripts/nvim-setup.sh")
