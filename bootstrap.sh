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
  ln -s ~/.config/nvim/init.lua ~/.vimrc
  echo

  echo 'installing vim-plug'
  curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  echo 'installing all plugins'
  nvim -c ":PlugInstall" -c ":qall"
  nvim -c ":MasonInstall eslint prettier prettierd" -c ":qall"
  echo 'installed all vim plugins'
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

# sync the home directory
read -r -p 'Symlink dotfiles to home directory? (y/n) '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  sync
fi

# install Node.js LTS, Volta
read -r -p 'Provision Node.js/Volta? (y/n) '
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  volta install node # volta installed by homebrew in Brewfile
  # install default packages
  echo 'installing default Nodejs package binaries, see .volta/default-packages'
  < .volta/default-packages xargs npm install -g
  # hack to speed up neovim with Volta, see https://github.com/neovim/neovim/issues/24371
  rm -rf "${HOME}/.config/yarn/global"
  mkdir -p "${HOME}/.config/yarn/global"
  ln -s "${HOME}/.volta/tools/shared" "${HOME}/.config/yarn/global/node_modules"
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
echo 'Decrypting key fetching code, supply bootstrap outer password'
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
echo 'You should restart.'
