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
brew tap buo/cask-upgrade

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --cleanup

# Install homebrew packages
brew install android-platform-tools
brew install bash
brew install git
brew install gpg
brew install keybase
brew install mobile-shell
brew install nvm
brew install openssl
brew install pyenv
brew install yarn

# Neovim
brew install neovim/neovim/neovim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

if ! cat /etc/shells | grep -q "/usr/local/bin/bash"; then
    # Add the new bash to our available shells
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    # switch current users shell to the new bash
    chsh -s /usr/local/bin/bash
fi

# Install homebrew cask packages
brew cask install bitcoin-core
brew cask install brave
# brew cask install color-oracle
brew cask install google-earth
brew cask install firefoxdeveloperedition  # or firefoxnightly, firefox-beta, firefox
brew cask install flux
brew cask install google-chrome
brew cask install gpgtools
brew cask install iterm2
brew cask install qlcolorcode
brew cask install qlstephen
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install resilio-sync
brew cask install sequel-pro
brew cask install slack
brew cask install transmission
brew cask install torbrowser
brew cask install vlc

# Install fonts
brew cask install font-source-code-pro
brew cask install font-source-code-pro-for-powerline

# Prompt user to install optional homebrew kegs
kegs=(
    # ansible
    aws-cli
    aws-elasticbeanstalk
    watchman              # Used by node to watch for file system changes
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
    1password
    audioscrobbler
    docker
    docker-compose  # Includes docker and docker-machine
    filezilla
    openbazaar
    spotify
    silverlight
    # vagrant
    # virtualbox
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

# Install Atom editor packages
if [ `type -P apm` ]; then
    echo "Installing Atom editor packages..."
    apm install --packages-file .atom/packages.txt
fi


# Cleanup
brew cask cleanup
brew cleanup
