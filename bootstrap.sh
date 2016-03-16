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
    source ~/.bash_profile;
}

# Homebrew OS X package manager
function install_homebrew() {
    echo "Installing Homebrew and packages..."
    source brew.sh

    # Install Atom editor packages
    if [ `type -P apm` ]; then
        echo "Installing Atom editor packages..."
        apm install --packages-file .atom/packages.txt
    fi
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

    # Install Node.js (Latest 'Stable')
    mkdir -p ~/.nvm
    # Setup NVM
    export NVM_DIR=~/.nvm
    . $(brew --prefix nvm)/nvm.sh
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
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

function provision_linux() {
    # we're in linux
    echo "Updating pacman database"
    sudo pacman -Sy
    echo "Actually installing shit..."
    # some base utils
    sudo pacman -S openssh \
                   vim \
                   rsync \
                   bluez \
                   bluez-utils

    # Install ACPI (battery utilities)
    sudo pacman -S acpi

    # Install X
    sudo pacman -S xf86-video-intel \
                   xf86-input-synaptics \
                   xorg-server \
                   xorg-init \
                   xautolock \
                   slock \
                   rxvt-unicode

    # Install X utilities and apps
    sudo pacman -S awesome \
                   vicious
    sudo pacman -S firefox \
                   bitcoin-qt \
                   vlc

    # Install Atom editor
    yaourt -S atom-editor
    # Install Atom editor packages
    if [ `type -P apm` ]; then
    echo "Installing Atom editor packages..."
        apm install --packages-file .atom/packages.txt
    fi

    # Install monitor calibration tools
    yaourt -S xcalib \
              xfluxd \
              btsync

    echo "Edit /etc/xfluxd.conf with your with lat/long coordinates"
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

# cleanup
unset sync;
unset install_homebrew;
unset install_rvm;
unset provision_darwin;
unset provision_linux;

# finish up
echo
echo "System has been bootstrapped."
echo "You probably should restart."
