#!/usr/bin/env bash
# Install homebrew and install packages.
# Author Ron. A @0xADADA

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install homebrew if it doesn't exist
if ! [ -x /usr/local/bin/brew ]; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Tap homebrew-cask and homebrew-cask versions
brew tap caskroom/cask
brew tap caskroom/versions

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Install homebrew packages
brew install git
brew install gpg
brew install keybase
brew install openssl
brew install mobile-shell
brew install android-platform-tools
brew install docker-compose # Includes docker and docker-machine
brew install nvm
brew install pyenv
# brew install ansible
# brew install awscli
# brew install aws-elasticbeanstalk

# Install homebrew cask packages
brew cask install atom
brew cask install audioscrobbler
brew cask install bitcoin-core
brew cask install bittorrent-sync
brew cask install diffmerge
brew cask install firefox
brew cask install flux
brew cask install filezilla
brew cask install gpgtools
brew cask install iterm2
brew cask install macvim
brew cask install qlcolorcode
brew cask install qlstephen
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install spotify
brew cask install sequel-pro
brew cask install transmission
brew cask install torbrowser
brew cask install vagrant
brew cask install virtualbox
brew cask install vlc
brew cask install google-chrome

# Cleanup
brew cleanup
