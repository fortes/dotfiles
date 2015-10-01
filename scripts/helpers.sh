# vim: fdm=marker

# Common Variables {{{
OS=`uname`

export OS
# }}}

# Colorful characters {{{
ARROW='↪'
CMARK='✓'
INFO='ℹ'
XMARK='✖'

if [ -t 1 ]; then
  # Use colors in terminal
  ARROW="$(tput setaf 2)$ARROW$(tput sgr0)"
  CMARK="$(tput setaf 2)$CMARK$(tput sgr0)"
  INFO="$(tput setaf 3)$INFO$(tput sgr0)"
  XMARK="$(tput setaf 1)$XMARK$(tput sgr0)"
fi

export CMARK XMARK
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

export -f isHomebrewPackageInstalled isAptPackageInstalled
# }}}
