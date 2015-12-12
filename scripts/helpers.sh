# vim: fdm=marker

# Common Variables {{{
OS=`uname`

export OS
export DOTFILES=$HOME/dotfiles
# }}}

# Colorful characters {{{
if [ $TERM = 'linux' ]; then
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
source "$HOME/.profile.local"
# }}}

# Helper functions {{{
isHomebrewTapInstalled() {
  if brew tap | grep -i $1 > /dev/null; then
    return 0
  else
    return 1
  fi
}

isHomebrewPackageInstalled() {
  if brew list $1 > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

# TODO: Allow taking a list of packages
installHomebrewPackageIfMissing() {
  if ! isHomebrewPackageInstalled $1; then
    echo "$XMARK $1 not installed"
    echo "  $ARROW Installing $1 via brew"
    brew install $1
  fi
  echo "$CMARK $1 installed"
}

isAptPackageInstalled() {
  if dpkg -s $1 > /dev/null 2> /dev/null; then
    return 0
  else
    return 1
  fi
}

isAptPPAInstalled() {
  if ls /etc/apt/sources.list.d | grep $1 > /dev/null; then
    return 0
  else
    return 1
  fi
}

# TODO: Allow taking a list of packages
installAptPackageIfMissing() {
  if ! isAptPackageInstalled $1; then
    echo "$XMARK Apt package $1 not installed"
    echo "  $ARROW Installing $1 (requires sudo)"
    sudo -E apt-get -qfuy install $1 > /dev/null
  fi
  echo "$CMARK $1 installed"
}

export -f isHomebrewPackageInstalled isHomebrewTapInstalled \
  installAptPackageIfMissing installHomebrewPackageIfMissing
# }}}
