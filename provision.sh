function install_or_upgrade_package {
  local package_name=$1; shift 1;

  if [ -z "$(/usr/local/bin/brew list -1 | grep $package_name)" ]; then
    brew install $package_name
  else
    brew upgrade $package_name 2> /dev/null
  fi
}

function install_or_upgrade_cask_package {
  local package_name=$1; shift 1;

  if [ -z "$(/usr/local/bin/brew cask list -1 | grep $package_name)" ]; then
    brew cask install $package_name
  fi
}

function install_homebrew {
  if ! [ -x /usr/local/bin/brew ]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  /usr/local/bin/brew update

  install_or_upgrade_package caskroom/cask/brew-cask
  brew tap caskroom/versions
}

# Install homebrew & homebrew cask
install_homebrew

# Install my homebrew packages
source Brewfile

# Install my homebrew casks
source Caskfile

# Cleanup
brew cleanup