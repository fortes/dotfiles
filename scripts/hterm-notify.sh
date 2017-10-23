#!/bin/sh

# Based on:
# https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/hterm-notify.sh

# Send a notification running under tmux.
# Usage: [title] [body]
notify_tmux() {
  local title="${1-}" body="${2-}"
  printf '\033Ptmux;\033\033]777;notify;%s;%s\a\033\\' "${title}" "${body}"
}

# Send a notification.
# Usage: [title] [body]
notify() {
  local title="${1-}" body="${2-}"
  case ${TERM-} in
  tmux*)
    notify_tmux "${title}" "${body}"
    ;;
  *)
    printf '\033]777;notify;%s;%s\a' "${title}" "${body}"
    ;;
  esac
}

# Write tool usage and exit.
# Usage: [error message]
usage() {
  if [ $# -gt 0 ]; then
    exec 1>&2
  fi

  cat <<EOF
Usage: hterm-notify [options] <title> [body]

Send a notification to hterm.

Notes:
- The title should not have a semi-colon in it.
- Neither field should have escape sequences in them.
  Best to stick to plain text.
EOF

  if [ $# -gt 0 ]; then
    echo "$@"
    exit 1
  else
    exit 0
  fi
}

main() {
  set -e

  while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        usage
        ;;
      -*)
        usage "Unknown option: $1"
        ;;
      *)
        break
        ;;
    esac
  done

  if [ $# -eq 0 ]; then
    usage "\nERROR: Missing message to send"
  fi

  if [ $# -gt 2 ]; then
    usage "\nERROR: Too many arguments"
  fi

  notify "$@"
}

main "$@"
