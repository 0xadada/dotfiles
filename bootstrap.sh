#!/usr/bin/env bash
# Provision a new Apple OS X machine
# Author Ron. A @0xADADA

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
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

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;

# Install XCcode command line tools
echo "Installing XCode command line tools..."
xcode-select --install

# Setup some python development tools
if ! which pip >/dev/null; then
    echo "Installing pip..."
    easy_install pip
fi

# Homebrew OS X package manager
function install_homebrew() {
    echo "Installing Homebrew and packages..."
    source brew.sh

    # Install Atom editor packages
    if [ `type -P apm` ]; then
        apm install --packages-file .atom/packages.txt
    fi
}

# call homebrew and homebrew cask scripts (installs NPM, etc)
read -p "Install Homebrew and all packages (y/n)?" choice
case "$choice" in
  y|Y ) install_homebrew;;
  n|N ) echo "Skipping homebrew";;
  * ) echo "invalid answer";;
esac

# Install Node.js (Latest 'Stable')
mkdir -p ~/.nvm
echo "Installing Node.js (Latest 'stable')..."
nvm install `nvm version-remote stable`

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
fi

# Ruby version manager
function install_rvm() {
    curl -sSL https://get.rvm.io | bash
    source ~/.profile
    rm ~/.profile
    rvm requirements
    rvm get stable
    rvm install ruby-head
}

read -p "Install rvm with curl | bash, Continue (y/n)?" choice
case "$choice" in
  y|Y ) install_rvm;;
  n|N ) echo "Skipping rvm";;
  * ) echo "invalid answer";;
esac

# Setup OS X system defaults
read -p "Setup OS X system defaults (y/n)?" choice
case "$choice" in
  y|Y ) source defaults.sh;;
  n|N ) echo "Skipping OS X defaults";;
  * ) echo "invalid answer";;
esac

# finish up
echo "System has been bootstrapped."
echo "You probably should restart."
