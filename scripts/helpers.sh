# vim: fdm=marker

# Common Variables {{{
OS=$(uname)

export OS
export DOTFILES=$HOME/dotfiles
# }}}

# Colorful characters {{{
if [ "$TERM" = 'linux' ]; then
  ARROW='>'
  CMARK='v '
  INFO='i '
  XMARK='x '
else
  ARROW='↪'
  CMARK='✓'
  INFO='ℹ'
  XMARK='✖'
fi

if [ -t 1 ]; then
  # Use colors in terminal
  ARROW="$(tput setaf 2)$ARROW$(tput sgr0)"
  CMARK="$(tput setaf 2)$CMARK$(tput sgr0)"
  INFO="$(tput setaf 3)$INFO$(tput sgr0)"
  XMARK="$(tput setaf 1)$XMARK$(tput sgr0)"
fi

export CMARK XMARK
if [ -r "$HOME/.profile.local" ]; then
  source "$HOME/.profile.local"
fi
# }}}

# Helper functions {{{
isHomebrewTapInstalled() {
  if brew tap | grep -i "$1" > /dev/null; then
    return 0
  else
    return 1
  fi
}

isHomebrewPackageInstalled() {
  if brew list "$1" > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

isHomebrewCaskPackageInstalled() {
  if brew cask list "$1" > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

installHomebrewCaskPackagesIfMissing() {
  PACKAGES=''

  for package in $@; do
    if ! isHomebrewCaskPackageInstalled "$package"; then
      echo "$XMARK Cask package $package not installed"
      PACKAGES="$PACKAGES $package"
    else
      echo "$CMARK Cask package $package installed"
    fi
  done

  if [ "$PACKAGES" != "" ]; then
    PACKAGES=$(echo "$PACKAGES" | xargs)
    echo "  $ARROW Installing$PACKAGES (requires sudo)"
    brew cask install "$PACKAGES"
    echo "$CMARK $PACKAGES installed"
  fi
}

installHomebrewPackagesIfMissing() {
  PACKAGES=''

  for package in $@; do
    if ! isHomebrewPackageInstalled "$package"; then
      echo "$XMARK Brew package $package not installed"
      PACKAGES="$PACKAGES $package"
    else
      echo "$CMARK Brew package $package installed"
    fi
  done

  if [ "$PACKAGES" != "" ]; then
    PACKAGES=$(echo "$PACKAGES" | xargs)
    echo "  $ARROW Installing $PACKAGES (requires sudo)"
    brew install $PACKAGES
    echo "$CMARK $PACKAGES installed"
  fi
}

isAptPackageInstalled() {
  if dpkg -s "$1" > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

installAptPackagesIfMissing() {
  PACKAGES=''

  for package in $@; do
    if ! isAptPackageInstalled "$package"; then
      echo "$XMARK Apt package $package not installed"
      PACKAGES="$PACKAGES $package"
    else
      echo "$CMARK Apt package $package installed"
    fi
  done

  if [  "$PACKAGES" != "" ]; then
    echo "  $ARROW Installing $PACKAGES (requires sudo)"
    sudo -E apt-get -qqfuy install $PACKAGES > /dev/null
    echo "$CMARK $PACKAGES installed"
  fi
}

export -f isHomebrewPackageInstalled isHomebrewTapInstalled \
  installAptPackagesIfMissing installHomebrewPackagesIfMissing
# }}}
