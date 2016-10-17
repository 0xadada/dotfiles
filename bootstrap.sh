#!/usr/bin/env bash
# Provision a new Apple OS X machine
# Author Ron. A @0xADADA

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function sync() {
    rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "defaults.sh" \
        --exclude "brew.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -av --no-perms . ~
}

# Homebrew OS X package manager
function install_homebrew() {
    echo "Installing Homebrew and packages..."
    source brew.sh
}

# Node version manager
function install_nvm() {
    # Install Node.js (Latest 'Stable')
    mkdir -p ~/.nvm
    # Setup NVM
    export NVM_DIR=~/.nvm
    [ -e /usr/share/nvm/init-nvm.sh ] && \
        source /usr/share/nvm/init-nvm.sh
    if [ `type -P brew` ]; then
        . $(brew --prefix nvm)/nvm.sh
    fi
    echo "Installing Node.js (Latest 'stable')..."
    nvm install node # "node" is an alias for latest stable
    nvm alias default node # set "node" as the default

    # update / install npm packages
    # Check for npm
    if [ `type -P npm` ]; then
        # Installing NPM packages...
        echo "Installing NPM packages..."
        npm install node-inspector --global --quiet
        npm install bower --global --quiet
        [[ $? ]] && echo "Done"
    else
        printf "\n"
        echo "Error: npm not found."
        printf "Aborting... try installing node packages manually\n"
        exit
    fi;
}

# Ruby version manager
function install_rvm() {
    curl -sSL https://get.rvm.io | bash
    source ~/.profile
    rm ~/.profile
    rvm requirements
    rvm get stable
    rvm install ruby-head
}

# Bootstrap provisioning for all OSes
function provision_universal() {
    read -p "Install nvm, Continue (y/n)? " choice
    case "$choice" in
      y|Y ) install_nvm;;
      n|N ) echo "Skipping nvm";;
      * ) echo "invalid answer";;
    esac

    echo "Installing VIM packages"
    echo ""
    mkdir -p ~/.vim/bundle
    # Install gruvbox color scheme
    git clone https://github.com/morhetz/gruvbox.git ~/.vim/bundle/gruvbox
    # Install EditorConfig plugin
    git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/bundle/editorconfig-vim
    vim -u NONE -c "helptags ~/.vim/bundle/editorconfig-vim/doc" -c q
    # Install NERDTree plugin
    git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
    vim -u NONE -c "helptags ~/.vim/bundle/nerdtree/doc" -c q
    # Install vim-airline plugin
    git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
    vim -u NONE -c "helptags ~/.vim/bundle/vim-airline/doc" -c q
    # Install vim-fugitive plugin
    git clone https://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
    vim -u NONE -c "helptags ~/.vim/bundle/vim-fugitive/doc" -c q
}

# Bootstrap provisioning for OS X
function provision_darwin() {
    # Install XCcode command line tools
    echo "Installing XCode command line tools..."
    xcode-select --install

    # call homebrew and homebrew cask scripts (installs NPM, etc)
    read -p "Install Homebrew and all packages (y/n)? " choice
    case "$choice" in
      y|Y ) install_homebrew;;
      n|N ) echo "Skipping homebrew";;
      * ) echo "invalid answer";;
    esac

    read -p "Install rvm with curl | bash, Continue (y/n)? " choice
    case "$choice" in
      y|Y ) install_rvm;;
      n|N ) echo "Skipping rvm";;
      * ) echo "invalid answer";;
    esac

    # Install Python (Latest 'Stable')
    echo "Installing Python (Latest 'stable')..."
    pyenv install `pyenv install --list | grep -v - | grep -v b | tail -1`

    # Setup OS X system defaults
    read -p "Setup OS X system defaults (y/n)? " choice
    case "$choice" in
      y|Y ) source defaults.sh;;
      n|N ) echo "Skipping OS X defaults";;
      * ) echo "invalid answer";;
    esac
}

function install_linux() {
    # Stuff to install after installing linux
    sudo pacman -Sy

    echo "General utilities"
    sudo pacman -S tree \
                   rsync \
                   which \
                   dialog \
                   wpa_supplicant

    echo "Power utilities"
    sudo pacman -S cpupower \
                   powertop \
                   acpi \
                   acpid
    yaourt -S      laptop-mode-tools \
                   mbpfan-git \
                   thermald
}

function provision_linux() {
    # we're in linux
    echo "Updating pacman database"
    sudo pacman -Sy

    echo "Actually installing shit..."
    # some base utils
    sudo pacman -S openssh \
                   keybase \
                   git \
                   vim \
                   bluez \
                   bluez-utils

    # Install X
    sudo pacman -S xf86-video-intel \
                   xf86-input-synaptics \
                   xorg-server \
                   xorg-init \
                   rxvt-unicode

    # Install X utilities and apps
    yaourt -S awesome \
              vicious \
              xbindkeys \
              xautolock \
              xorg-xsetroot \
              slock \
              lain-git  # Layouts n shit, yo

    # install some great fonts
    yaourt -S noto-fonts-emoji \
              terminus-font \
              adobe-source-sans-pro-fonts \
              adobe-source-serif-pro-fonts \
              adobe-source-code-pro-fonts \
              otf-sauce-code-powerline-git \  # Adobe Source Code Pro (Patched for Powerline)
              ttf-twitter-color-emoji-svginot # Twitter Emoji for Everyone

    # install keyboard / IME tools
    yaourt -S ibus \
              ibus-uniemoji-git

    # Install monitor calibration tools
    yaourt -S xcalib \
              xflux \
              xfluxd \
              kbdlight

    # Install some useful applications
    yaourt -S rslsync \
              nvm-git \
              pyenv \
              firefox-beta-bin \
              google-chrome \
              google-earth \
              mpv \
              mysql-workbench \
              spotify \
              android-tools \
              bitcoin-qt \
              transmission-gtk
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

# Provision GNU/Linux applications
if [[ $OSTYPE == linux* ]]; then
    read -p "Provision Linux software? (y/n)? " choice
    case "$choice" in
      y|Y ) provision_linux;;
      n|N ) echo "Skiping Linux provisioning";;
      * ) echo "invalid answer";;
    esac
fi

# Provision any OS-non specific applications
read -p "Provision non-specific OS software? (y/n)? " choice
case "$choice" in
  y|Y ) provision_any;;
  n|N ) echo "Skiping provisioning";;
  * ) echo "invalid answer";;
esac

# cleanup
unset sync;
unset install_homebrew;
unset install_nvm;
unset install_rvm;
unset provision_universal;
unset provision_darwin;
unset provision_linux;

# finish up
echo
echo "System has been bootstrapped."
echo "You probably should restart."
