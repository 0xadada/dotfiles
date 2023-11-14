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
brew upgrade --cask # --greedy to force auto-upgrade existing casks
brew cleanup

# switch from system Bash to Homebrew Bash
if ! grep -q '/usr/local/bin/bash' /etc/shells; then
  # Add the new bash to our available shells
  echo 'switching shell to latest homebrew bash'
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash
fi

# install nvm, and latest node
read -r -p 'Provision nvm/nodejs? (y/n) '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  export NVM_DIR="$HOME/.nvm"
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  # shellcheck disable=SC2164
  cd "$NVM_DIR"
  git checkout "$(git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")"
  # shellcheck disable=SC1090,SC1091
  \. "$NVM_DIR/nvm.sh"
  nvm install --lts
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
read -r -p '.macOS system defaults (y/n)? '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  # shellcheck disable=SC1091
  source .macos
  # set default macOS Launchpad settings & folders
  lporg load ~/.launchpad.yaml --no-backup
fi

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
