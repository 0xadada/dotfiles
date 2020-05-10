#!/usr/bin/env bash

set -x

os_defaults=$(which defaults)

# a wrapper for macOS defaults to enable logging and debugging
function defaults() {
  printf "%s " "${@:1}"
  set -- "read" "${@:2}"
  printf "%s " "${@:1}"
  echo "args $@"
  $os_defaults "$@"
  exit 1

  if [[ "${command}" == "write" ]]; then
    echo "switching to read"
    args[0]='read'
    echo ${args[0]}
    exit 1
  fi
  echo "$os_defaults $command $2 $3 $4 $5"
  $os_defaults $command $2 $3 $4
}

defaults write com.apple.print.PrintingPrefs 'Quit When Finished' # -bool True
#defaults -currentHost write com.apple.screensaver idleTime 180
