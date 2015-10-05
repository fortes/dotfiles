#/bin/bash
set -euf -o pipefail
source $HOME/dotfiles/scripts/helpers.sh

if ! which fzf > /dev/null; then
  echo "$XMARK FZF not installed"

  if [ "$OS" = 'Darwin' ]; then
    echo "  $ARROW Installing FZF"
    brew reinstall --HEAD fzf
  else
    echo "  $ARROW Installing FZF"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    echo "  $ARROW Running FZF install script"
    (~/.fzf/install)
  fi
fi

echo "$CMARK FZF installed"
