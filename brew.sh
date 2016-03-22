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

# Tap homebrew-cask versions
brew tap caskroom/fonts
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

# Install homebrew cask packages
brew cask install atom
brew cask install bitcoin-core
brew cask install bittorrent-sync
brew cask install diffmerge
brew cask install firefox
brew cask install flux
brew cask install gpgtools
brew cask install iterm2
brew cask install macvim
brew cask install qlcolorcode
brew cask install qlstephen
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install sequel-pro
brew cask install transmission
brew cask install torbrowser
brew cask install virtualbox
brew cask install vlc

# Install fonts
brew cask install caskroom/fonts/font-hack
brew cask install caskroom/fonts/font-source-code-pro
brew cask install caskroom/fonts/font-sauce-code-powerline

# Prompt user to install optional homebrew kegs
kegs=(
    ansible
    aws-cli
    aws-elasticbeanstalk
)

for item in ${kegs[*]}
do
    read -p "Install $item (y/n)? " choice
    case "$choice" in
      y|Y ) echo " Installing $item..."
        brew install $item
        ;;
      n|N ) echo " Skipping $item"
        ;;
      * ) echo "invalid answer";;
    esac
done

# Prompt user to install optional homebrew casks
casks=(
    audioscrobbler
    filezilla
    google-chrome
    spotify
    silverlight
    vagrant
)
for item in ${casks[*]}
do
    read -p "Install $item (y/n)? " choice
    case "$choice" in
      y|Y ) echo " Installing $item..."
        brew cask install $item
        ;;
      n|N ) echo " Skipping $item"
        ;;
      * ) echo "invalid answer";;
    esac
done

# Cleanup
brew cleanup
