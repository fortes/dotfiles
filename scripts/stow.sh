#!/bin/bash
stow --dir="$HOME/dotfiles/stowed-files/" --target="$HOME" \
  $(ls "$HOME"/dotfiles/stowed-files) $@
