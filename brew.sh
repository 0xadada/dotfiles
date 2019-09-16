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

# Tap homebrew-cask versions
brew tap caskroom/fonts
brew tap caskroom/versions
brew tap buo/cask-upgrade  # CLI for upgrading every outdated app installed cask

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --cleanup

# Install homebrew packages
brew install asdf
brew install bash
brew install docker-compose  # Includes docker and docker-machine
brew install git
brew install pinentry-mac  # fixes git signing issue
brew install mobile-shell
brew install openssl
brew install pyenv  # not used, but required for asdf-python
brew install rg  # ripgrep, used by neovim::denite plugin
brew install watchman  # Used by node to watch for file system changes
brew install yarn --without-node  # dont need node, I use asdf

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
brew cask install firefox-developer-edition  # or firefoxnightly, firefox-beta, firefox
brew cask install google-chrome-canary
brew cask install gpg-suite-no-mail
brew cask install imageoptim
brew cask install iterm2
brew cask install protonvpn
brew cask install qlcolorcode
brew cask install qlstephen
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install resilio-sync
brew cask install signal
brew cask install spectacle
brew cask install slack
brew cask install tor-browser

# Install fonts
brew cask install font-source-code-pro
brew cask install font-source-code-pro-for-powerline
brew cask install font-twitter-color-emoji

# Prompt user to install optional homebrew kegs
kegs=(
    android-platform-tools
    awscli
    postgresql
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
    brave
    docker
    google-chrome
    google-earth
    keybase
    sequel-pro
    psequel
    spotify
    transmission
    vlc
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
brew cask cleanup
brew cleanup
