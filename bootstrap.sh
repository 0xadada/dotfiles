#!/usr/bin/env bash
# Provision a new Apple Macbook
# Author @0xADADA


# list installed language package versions on a single line
# usage: asdf_list_package_sorted 'python'
function asdf_list_package_sorted() {
  package=$1
  asdf list "${package}" | \
    sed -e 's/^[ ]*//' | \
    sort -n | \
    tr '\n' ' '
}

function sync() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".macos" \
    --exclude "ansible" \
    --exclude "bootstrap.sh" \
    --exclude "iTerm" \
    --exclude "README.md" \
    --exclude "LICENSE" \
    -av --no-perms . $HOME
}

# Bootstrap provisioning for vim
function provision_vim() {
  echo 'Installing VIM packages'
  # finalize Neovim
  rm -rf ~/.vim*
  ln -s ~/.config/nvim ~/.vim
  ln -s ~/.config/nvim/init.vim ~/.vimrc
  echo ''

  echo 'installing neovim language deps'
  npm install -g neovim
  gem install neovim
  pip install pynvim  #install dependency for Denite

  echo 'installing vim-plug'
  curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  echo 'installing all plugins'
  nvim -c ":PlugInstall" -c ":qall"
  echo 'installed all vim plugins'

  echo 'install coc.nvim language servers'
  nvim -c ":CocInstall coc-tsserver coc-eslint coc-prettier coc-html coc-css coc-json coc-python coc-yaml" \
    -c ":qall"
  echo ' installed coc.nvim language servers'
}

sudo -v # ask for the administrator password upfront.

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install homebrew (ProTip: homebrew installs xcode CLI tools for us!)
if ! [[ $(command -v brew) ]]; then
  echo 'Installing Homebrew...'
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo 'Installing Homebrew taps, kegs, casks, and brews...'
brew update
brew bundle
brew upgrade # upgrade installed formulae
brew cask upgrade # --greedy to force auto-upgrade casks
brew cleanup

# switch from system Bash to Homebrew Bash
if ! cat /etc/shells | grep -q "/usr/local/bin/bash"; then
  # Add the new bash to our available shells
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
  echo 'switch current shell to homebrew bash'
  chsh -s /usr/local/bin/bash
fi

# Install asdf programming language plugins
echo 'Installing asdf programming language package...'
# Setup asdf (installed via homebrew)
source /usr/local/opt/asdf/asdf.sh
asdf plugin add elixir || true
asdf plugin add erlang || true
asdf plugin add python || true
asdf plugin add nodejs || true
asdf plugin add ruby || true
asdf plugin-update --all

# install latest NodeJS, set it globally
latest=$(asdf list-all nodejs | grep '^\b[0-9]*[02468]\b' | tail -n 1)
current=$(asdf_list_package_sorted 'nodejs')
if ! [[ "${current}" =~ "${latest}" ]]; then
  echo "Installing NodeJS ${latest}..."
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  asdf install nodejs $latest
  asdf global nodejs $latest
  echo 'Installing global node tools...'
  npm install -g \
    ember-cli \
    tldr \
    yarn
fi

# install latest erlang, set it globally
latest=$(asdf list-all erlang | grep -E '^(\d+).(\d+).(\d+)$' | tail -n 1)
current=$(asdf_list_package_sorted 'erlang')
if ! [[ "${current}" =~ "${latest}" ]]; then
  echo "Installing latest Erlang ${latest}..."
  asdf install erlang $latest
  asdf global erlang $latest
fi

# install latest elixir, set it globally
latest=$(asdf list-all elixir | grep -E '^(\d+).(\d+).(\d+)$' | tail -n 1)
current=$(asdf_list_package_sorted 'elixir')
if ! [[ "${current}" =~ "${latest}" ]]; then
  echo "Installing latest Elixir ${latest}..."
  asdf install elixir $latest
  asdf global elixir $latest
fi

# install latest Python 3
latest=$(asdf list-all python | grep -E '^3.(\d+).(\d+)$' | tail -n1)
current=$(asdf_list_package_sorted 'python')
if ! [[ "${current}" =~ "${latest}" ]]; then
  echo "Installing latest Python ${latest}..."
  # setup a fix for openssl in python
  LDFLAGS="-L$(brew --prefix openssl)/lib"
  CPPFLAGS="-I$(brew --prefix openssl)/include"
  CFLAGS="-I$(brew --prefix openssl)/include"
  # install latest python 3
  asdf install python $latest
  asdf global python $latest
fi

# install latest ruby, set it globally
latest=$(asdf list-all ruby | grep -E '^(\d+).(\d+).(\d+)$' | tail -n1)
current=$(asdf_list_package_sorted 'ruby')
if ! [[ "${current}" =~ "${latest}" ]]; then
  echo "Installing latest Ruby ${latest}..."
  asdf install ruby $latest
  asdf global ruby $latest
fi

# Install Python3 / Ansible
if ! [[ $(command -v ansible) ]]; then
  echo 'Installing Ansible...'
  echo "Using $(python -V)"
  pip install ansible
  # see https://github.com/danhper/asdf-python#pip-installed-modules-and-binaries
  asdf reshim python
  echo "Ansible installed at $(which ansible)"
fi

echo 'Installing tools with Ansible'
ansible-playbook \
  --ask-become-pass \
  ansible/main.yml

# Remove garageband
sudo rm -rfv /Applications/GarageBand.app && \
  rm -rfv /Library/Application\ Support/GarageBand && \
  rm -rfv /Library/Application\ Support/Logic/ && \
  rm -rfv /Library/Audio/Apple\ Loops && \
  rm -rfv /Library/Audio/Apple\ Loops\ Index && \
  rm -rfv /Library/Receipts/com.apple.pkg.*GarageBand* && \
  rm -rfv ~/Library/Audio/Apple Loops && \
  rm -rfv ~/Library/Application\ Support/GarageBand

# sync if the --force argument was passed
if [ "$1" == "--force" -o "$1" == "-f" ]; then
  sync;
else
  # else ask
  read -p 'Symlinking dotfiles to $HOME directory. Are you sure? (y/n) ' -n 1;
  echo '';
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sync;
  fi;
fi;

# Provision any vim specific deps
read -p 'Provision vim? (y/n)? ' choice
case "$choice" in
  y|Y ) provision_vim;;
  n|N ) echo 'Skiping provisioning';;
  * ) echo 'invalid answer';;
esac

# Setup OS X system defaults
read -p 'Personalize macOS system defaults (y/n)? ' choice
case "$choice" in
y|Y ) source .macos;;
n|N ) echo 'Skipping macOS defaults';;
* ) echo 'invalid answer';;
esac

echo 'installing notify-on-packetloss launchd service'
mkdir -p nop && \
  curl -#L https://github.com/0xadada/notify-on-packetloss/tarball/master | \
  tar -xzv -C nop --strip-components=1
pushd nop
source install.sh
popd
rm -rf nop # cleanup tmp dir

# finish up
echo
echo 'System has been bootstrapped.'
echo 'You probably should restart.'
