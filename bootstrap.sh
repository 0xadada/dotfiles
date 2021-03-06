#!/usr/bin/env bash
# Provision a new Apple Macbook
# Author @0xADADA

# sync dotfiles to $HOME
function sync() {
  rsync --exclude ".git/" \
    --exclude ".github" \
    --exclude ".DS_Store" \
    --exclude ".macos" \
    --exclude "avatar.jpg" \
    --exclude "bootstrap.sh" \
    --exclude "Brewfile" \
    --exclude "iTerm" \
    --exclude "README.md" \
    --exclude "LICENSE" \
    -av --no-perms . "${HOME}"
}

# list latest installed languages major/minor version number
# usage: asdf_list_package_sorted 'python'
# output: 3.8 2.7
function asdf_list_package_sorted() {
  package=$1
  asdf list "${package}" | \
    sed -e 's/^[ ]*//' | \
    sort -n | \
    tr '.' ' ' | \
    awk '{print $1 "." $2}' | \
    xargs echo
}

# Bootstrap provisioning for vim
function provision_vim() {
  echo 'Installing VIM packages'
  # finalize Neovim
  rm -rf ~/.vim*
  ln -s ~/.config/nvim ~/.vim
  ln -s ~/.config/nvim/init.vim ~/.vimrc
  echo

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
  local servers=(coc-tsserver \
                 coc-eslint \
                 coc-prettier \
                 coc-html \
                 coc-css \
                 coc-json \
                 coc-python \
                 coc-yaml)
  nvim -c ":CocInstall ${servers[*]}" -c ":qall"
  echo "installed coc.nvim servers: ${servers[*]}"
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
brew cask upgrade # --greedy to force auto-upgrade existing casks
brew cleanup

# fix for QuickLook plugins, see: https://github.com/whomwah/qlstephen#permissions-quarantine
xattr -d com.apple.quarantine ~/Library/QuickLook/*
qlmanage -r && qlmanage -r cache

# switch from system Bash to Homebrew Bash
if ! grep -q '/usr/local/bin/bash' /etc/shells; then
  # Add the new bash to our available shells
  echo 'switching shell to latest homebrew bash'
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash
fi

# Install asdf programming language plugins
echo 'Installing asdf programming language package...'
# Setup asdf (installed via homebrew)
# shellcheck disable=SC1090,SC1091
source "$(brew --prefix asdf)/asdf.sh"
asdf plugin add elixir || true
asdf plugin add erlang || true
asdf plugin add python || true
asdf plugin add nodejs || true
asdf plugin add ruby || true
asdf plugin-update --all

# install latest NodeJS, set it globally
latest=$(asdf list-all nodejs | grep '^\b[0-9]*[02468]\b' | tail -n1)
current=$(asdf_list_package_sorted 'nodejs')
if ! [[ "${latest}" =~ ${current} ]]; then
  echo "Installing NodeJS ${latest}..."
  bash "${HOME}/.asdf/plugins/nodejs/bin/import-release-team-keyring"
  asdf install nodejs "${latest}"
  asdf global nodejs "${latest}"
  echo 'Installing global node tools...'
  npm install -g \
    ember-cli \
    neovim \
    tldr \
    yalc \
    yarn
fi

# install latest erlang, set it globally
latest=$(asdf list-all erlang | grep -E '^(\d+).(\d+).(\d+)$' | tail -n1)
current=$(asdf_list_package_sorted 'erlang')
if ! [[ "${latest}" =~ ${current} ]]; then
  echo "Installing latest Erlang ${latest}..."
  asdf install erlang "${latest}"
  asdf global erlang "${latest}"
fi

# install latest elixir, set it globally
latest=$(asdf list-all elixir | grep -E '^(\d+).(\d+).(\d+)$' | tail -n1)
current=$(asdf_list_package_sorted 'elixir')
if ! [[ "${latest}" =~ ${current} ]]; then
  echo "Installing latest Elixir ${latest}..."
  asdf install elixir "${latest}"
  asdf global elixir "${latest}"
fi

# install latest Python 3
latest=$(asdf list-all python | grep -E '^(\d+).(\d+).(\d+)$' | tail -n1)
current=$(asdf_list_package_sorted 'python')
if ! [[ "${latest}" =~ ${current} ]]; then
  echo "Installing latest Python ${latest}..."
  # a fix for openssl in python
  LDFLAGS="-L$(brew --prefix openssl)/lib"
  export LDFLAGS
  CPPFLAGS="-I$(brew --prefix openssl)/include"
  export CPPFLAGS
  CFLAGS="-I$(brew --prefix openssl)/include"
  export CFLAGS
  # install latest python 3
  asdf install python "${latest}"
  asdf global python "${latest}"
  # see https://github.com/danhper/asdf-python#pip-installed-modules-and-binaries
  asdf reshim python
fi

# install latest ruby, set it globally
latest=$(asdf list-all ruby | grep -E '^(\d+).(\d+).(\d+)$' | tail -n1)
current=$(asdf_list_package_sorted 'ruby')
if ! [[ "${latest}" =~ ${current} ]]; then
  echo "Installing latest Ruby ${latest}..."
  asdf install ruby "${latest}"
  asdf global ruby "${latest}"
fi

# sync the home directory
read -r -p 'Symlink dotfiles to home directory? (y/n) '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  sync
fi

# Provision any vim specific deps
read -r -p 'Provision vim? (y/n) '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  provision_vim
fi

# Setup macOS defaults
read -r -p 'Personalize macOS system defaults (y/n)? '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  source .macos
fi

echo 'installing notify-on-packetloss launchd service'
mkdir -p nop && \
  curl -#L https://github.com/0xadada/notify-on-packetloss/tarball/master | \
  tar -xzv -C nop --strip-components=1
pushd nop || exit 1
# shellcheck disable=SC1091
source install.sh
popd || exit 1
rm -rf nop # cleanup tmp dir

# eval some 'arbitrary code' to fetch some keys, some fucking voodoo magick
echo 'Decrypting key fetching code'
fetch_keys=$(echo '-----BEGIN PGP MESSAGE-----

jA0ECQMCTI5gnl9FVkHr0sABAbfFWVjvv8SDVeQaxGkS6ItbJuWIXWLYdvsgqg+O
G/hY4b7g7ibgs236Cvz225f7SZ0FLF/rQj9n7kD17HzO+BT/+VHllntne6BL80cI
Vyha0ZlGMWe1ndgg82NByt7DdO6KCz9ZP+DjSxICiKk8z5wzJTpBUgGuhlMNVXJX
g4sh7i5QcDG65eoeIALhm+wI6isIWt88TKUknSF2hQ9RNK1fFC2GcBAYxd5Gxjl1
IVgHE95esgVWZurCRjYi8eKjsQ==
=RcJ8
-----END PGP MESSAGE-----' | gpg --pinentry-mode loopback -d - 2> /dev/null)
eval "${fetch_keys}"

# finalize .bash_custom settings
${EDITOR} "${HOME}/.bash_custom"

# finish up
echo
echo 'System has been bootstrapped 💫'
echo 'You probably should restart.'
