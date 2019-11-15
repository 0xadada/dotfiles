#!/usr/bin/env bash
# Install homebrew and install packages.
# Author @0xADADA

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install homebrew if it doesn't exist
if ! [ -x /usr/local/bin/brew ]; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install all the fun
brew bundle

# Upgrade any already-installed formulae.
brew upgrade --cleanup

# finalize Bash
if ! cat /etc/shells | grep -q "/usr/local/bin/bash"; then
  # Add the new bash to our available shells
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
  # switch current users shell to the new bash
  chsh -s /usr/local/bin/bash
fi

# cleanup
brew cask cleanup
brew cleanup
