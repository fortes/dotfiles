#!/bin/bash
source $HOME/dotfiles/scripts/helpers.sh

show_help() {
  cat << EOF
Usage: ${0##*/} [-hf]
Setup symlinks to files in dotfiles repo

  -h          Show this message and exit
  -f          Overwrite existing files
EOF
}

FORCE=''
while getopts fh o; do
  case "$o" in
    f) FORCE=1;;
    ?) show_help; exit;; 
  esac
done

ERRORS=''
for file in $HOME/dotfiles/symlinks/*; do
  target=$HOME/.`basename $file`
  if [ -e $target ] || [ -L $target ]; then
    if ! diff -q $target $file > /dev/null 2> /dev/null; then
      if [ -n "$FORCE" ]; then
        old_path=$HOME/old.`basename $file`
        >&2 echo "$XMARK $target already exists!"
        >&2 echo "  $ARROW Moved $target to $old_path"
        mv $target $old_path && ln -s $file $target
        echo "$CMARK $target linked"
      else
        ERRORS="$ERRORS$XMARK $target already exists and differs\n"
      fi
    fi
  else
    ln -s $file $target
    echo "$CMARK $target linked"
  fi
done

if [ -n "$ERRORS" ]; then
  # Use printf instead of echo since we have a trailing newline
  >&2 printf "$ERRORS"
  >&2 printf "\nOverwrite old files with '${0##*/} -f'\n"
  exit 1
else
  echo "$CMARK All dotfiles files linked"
fi
