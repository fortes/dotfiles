#!/bin/bash
# shellcheck source=helpers.sh
source "$HOME/dotfiles/scripts/helpers.sh"

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
for file in $DOTFILES/symlinks/*; do
  target=$HOME/.`basename $file`
  if [ -e "$target" ]; then
    if [[ "$(readlink $target)" != "$file" ]]; then
      if [ -d "$target" ]; then
        echo "  $ARROW moving existing files in $target/"
        for ofile in $target/*; do
          echo "    $ARROW moving $ofile"
          mv "$ofile" "$file/."
        done
        rmdir "$target"
        ln -s "$file" "$target"
        echo "$CMARK $target linked"
      elif [ -n "$FORCE" ]; then
        old_path=$HOME/old.`basename $file`
        >&2 echo "$XMARK $target already exists!"
        >&2 echo "  $ARROW Moved $target to $old_path"
        mv "$target" "$old_path" && ln -s "$file" "$target"
        echo "$CMARK $target linked"
      else
        ERRORS="$ERRORS$XMARK $target already exists and differs\n"
      fi
    fi
  else
    ln -s "$file" "$target"
    echo "$CMARK $target linked"
  fi
done

if [ ! -f "$DOTFILES/symlinks/ssh/config" ]; then
  echo "  $ARROW Creating ~/.ssh/config"
  cp "$DOTFILES/symlinks/ssh/config.sample" "$DOTFILES/symlinks/ssh/config"
  echo "$CMARK ~/.ssh/config created"
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo "  $ARROW Creating ~/.gitconfig.local"
  cp "$DOTFILES/symlinks/config/git/config.local.sample" "$HOME/.gitconfig.local"
  echo "$CMARK ~/.gitconfig.local created"
fi

if [ -n "$ERRORS" ]; then
  # Use printf instead of echo since we have a trailing newline
  >&2 printf "%s" "$ERRORS"
  >&2 printf "\nOverwrite old files with '%s'\n" "${0##*/} -f"
  exit 1
else
  echo "$CMARK All dotfiles files linked"
fi
