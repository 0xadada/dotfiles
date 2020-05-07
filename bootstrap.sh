#!/usr/bin/env bash
# Provision a new Apple macOS machine
# Author @0xADADA


sudo -v # ask for the administrator password upfront.

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

if ! command -v xcode-select > /dev/null
then
  echo 'Installing xcode command line tools...'
  xcode-select --install
fi

if ! [ -x /usr/local/bin/brew ]; then
  echo 'Installing Homebrew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo 'Installing Homebrew taps, kegs, casks, and brews...'
brew update
brew bundle
brew upgrade # upgrade installed formulae
brew cask upgrade --greedy # force auto-upgrade casks
brew cleanup

# switch from system Bash to Homebrew Bash
if ! cat /etc/shells | grep -q "/usr/local/bin/bash"; then
  # Add the new bash to our available shells
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
  # switch current users shell to the new bash
  chsh -s /usr/local/bin/bash
fi

echo 'Installing Yarn packages'
yarn global add tldr

echo 'Installing Ansible'
PATH="${HOME}/Library/Python/3.7/bin:${PATH}"
pip3 install --user ansible

echo 'Installing tools with Ansible'
ansible-playbook \
  --ask-become-pass \
  ansible/main.yml

function sync() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".macos" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "LICENSE" \
    -av --no-perms . ~
  # add SSH key to macOS keychain
  echo "⚠️  Adding SSH key to macOS Keychain⚠️  "
  ssh-add -K ~/.ssh/id_rsa
}


function install_asdf() {
  # Setup asdf (installed via homebrew)
  source /usr/local/opt/asdf/asdf.sh
  asdf update
  asdf plugin-add elixir
  asdf plugin-add erlang
  asdf plugin-add python
  asdf plugin-add nodejs
  asdf plugin-add ruby
  asdf plugin-update --all
  # install latest 8-branch Nodejs, set it globally
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  asdf install nodejs $(asdf list-all nodejs | grep '^\b[0-9]*[02468]\b' | tail -n 1)
  asdf global nodejs $(asdf list nodejs | tail -n 1)
  # install latest erlang, set it globally
  asdf install erlang $(asdf list-all erlang | grep -E '^(\d+).(\d+).(\d+)$' | tail -n 1)
  asdf global erlang $(asdf list erlang | tail -n 1)
  # install latest elixir, set it globally
  asdf install elixir $(asdf list-all elixir | grep -E '^(\d+).(\d+).(\d+)$' | tail -n 1)
  asdf global elixir $(asdf list elixir | tail -n 1)
  # setup a fix for openssl in python
  brew link --force openssl
  LDFLAGS="-L$(brew --prefix openssl)/lib"
  CPPFLAGS="-I$(brew --prefix openssl)/include"
  CFLAGS="-I$(brew --prefix openssl)/include"
  # install latest python2
  asdf install python $(asdf list-all python | grep -E '^2.(\d+).(\d+)$' | tail -n1)
  # install latest python3
  asdf install python $(asdf list-all python | grep -E '^3.(\d+).(\d+)$' | tail -n1)
  # set python3 default with python2 fallback
  asdf global python $(asdf list python | tail -n2 | sort -r | xargs echo -n)
  # install latest ruby, set it globally
  asdf install ruby $(asdf list-all ruby | grep -E '^(\d+).(\d+).(\d+)$' | tail -n 1)
  asdf global ruby $(asdf list ruby | tail -n 1)
}

# Bootstrap provisioning for all OSes
function provision_universal() {
  read -p "Install asdf, Continue (y/n)? " choice
  case "$choice" in
    y|Y ) install_asdf;;
    n|N ) echo "Skipping asdf";;
    * ) echo "invalid answer";;
  esac
}

# Bootstrap provisioning for vim
function provision_vim() {
  echo "Installing VIM packages"
  # finalize Neovim
  rm -rf ~/.vim*
  ln -s ~/.config/nvim ~/.vim
  ln -s ~/.config/nvim/init.vim ~/.vimrc
  echo ""

  # install neovim language deps
  yarn global add neovim
  gem install neovim
  pip3 install pynvim  #install dependency for Denite

  # install vim-plug
  curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    echo "installed vim-plug"
  nvim -c ":PlugInstall" -c ":qall" && echo "installed all vim plugins"

  # install coc.nvim language servers
  nvim -c ":CocInstall coc-tsserver coc-eslint coc-prettier coc-html coc-css coc-json coc-python coc-yaml" \
    -c ":qall" && \
    echo " installed coc.nvim language servers"
}

# Bootstrap provisioning for OS X
function provision_darwin() {
  # Remove garageband
  pkgutil --forget com.apple.pkg.GarageBand_AppStore
  pkgutil --forget com.apple.pkg.GarageBandBasicContent
  sudo rm -rfv /Applications/GarageBand.app && \
    rm -rfv /Library/Application\ Support/GarageBand && \
    rm -rfv /Library/Application\ Support/Logic/ && \
    rm -rfv /Library/Audio/Apple\ Loops && \
    rm -rfv /Library/Audio/Apple\ Loops\ Index && \
    rm -rfv /Library/Receipts/com.apple.pkg.*GarageBand* && \
    rm -rfv ~/Library/Audio/Apple Loops && \
    rm -rfv ~/Library/Application\ Support/GarageBand

  # Setup OS X system defaults
  read -p "Personalize macOS system defaults (y/n)? " choice
  case "$choice" in
    y|Y ) source .macos;;
    n|N ) echo "Skipping OS X defaults";;
    * ) echo "invalid answer";;
  esac

  # install notify-on-packetloss launchd service
  git clone -q git@github.com:0xadada/notify-on-packetloss.git asdftmp # tmp dir
  pushd asdftmp
  source install.sh
  popd
  rm -rf asdftmp # cleanup tmp dir
}


if [ "$1" == "--force" -o "$1" == "-f" ]; then
  sync;
else
 read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
 echo "";
 if [[ $REPLY =~ ^[Yy]$ ]]; then
   sync;
 fi;
fi;

# Provision OS X applications
if [[ $OSTYPE == darwin* ]]; then
  read -p "Provision OS X software? (y/n)? " choice
  case "$choice" in
    y|Y ) provision_darwin;;
    n|N ) echo "Skiping OS X provisioning";;
    * ) echo "invalid answer";;
  esac
fi

# Provision any vim specific deps
read -p "Provision vim? (y/n)? " choice
case "$choice" in
  y|Y ) provision_vim;;
  n|N ) echo "Skiping provisioning";;
  * ) echo "invalid answer";;
esac

# Provision any OS-non specific applications
read -p "Provision non-specific OS software? (y/n)? " choice
case "$choice" in
  y|Y ) provision_universal;;
  n|N ) echo "Skiping provisioning";;
  * ) echo "invalid answer";;
esac

# cleanup
unset sync;
unset install_asdf;
unset provision_universal;
unset provision_vim;
unset provision_darwin;

# finish up
echo
echo "System has been bootstrapped."
echo "You probably should restart."
