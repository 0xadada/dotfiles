#!/usr/bin/env bash

# set -x

os_defaults=$(which defaults)

# Set the colors you can use
red=$(tput setaf 124)
green=$(tput setaf 142)
reset=$(tput sgr0) # resets the style

# color-echo
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# a wrapper for macOS defaults to enable logging and debugging
function defaults() {
  # write existing defaults to a file
  $os_defaults read > defaults.before.log

  # value
  defaults_write=''

  # handles: defaults write... case
  # if the first of 1 arguments is write
  if [[ "${@:1:1}" == 'write' ]]; then
    # store original value
    defaults_write="${@:5:1}"
    # set the first positional param to 'read', and append all args from the 2nd
    set -- "read" "${@:2}"
  fi

  # handles: defaults -currentHost write... case
  # if the 2nd of 1 args is write
  if [[ "${@:2:1}" == 'write' ]]; then
    # store original value
    defaults_write="${@:5:1}"
    # use 1st arg, replace 2nd with 'read', and append all args from the 3rd
    set -- "${@:1:1}" "read" "${@:3}"
  fi

  # call defaults with adjusted 'read' params
  defaults_read=$($os_defaults "$@")

  # handles: defaults write... case
  # if the first of 1 arguments is read
  if [[ "${@:1:1}" == 'read' ]]; then
    # set the first positional param to 'write', and append all args from the 2nd
    set -- "write" "${@:2}"
  fi

  # handles: defaults -currentHost read... case
  # if the 2nd of 1 args is write
  if [[ "${@:2:1}" == 'read' ]]; then
    # use 1st arg, replace 2nd with 'write', and append all args from the 3rd
    set -- "${@:1:1}" "write" "${@:3}"
  fi

  # if the values are different, then run defaults write
  if [[ "${defaults_read}" != "${defaults_write}" ]]; then
    # values are different, execute
    $os_defaults "$@"
    # output command
    echo "defaults ${@}"
    # output changed values
    cecho "- ${defaults_read}" $red
    cecho "+ ${defaults_write}" $green
  fi

  # write defaults after to file
  $os_defaults read > defaults.after.log
}

defaults -currentHost write com.apple.screensaver idleTime 180
defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool 1
