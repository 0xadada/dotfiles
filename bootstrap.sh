#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"
git pull origin master
function doIt() {
    rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
        --exclude "README.md" --exclude "LICENSE-MIT.txt" \
        --exclude "Brewfile" --exclude ".cask" --exclude ".osx" \
        -av --no-perms . ~
    source ~/.bash_profile
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt
    fi
fi
unset doIt

# update homebrew packages
if [ `type -P brew` ]; then
    echo "Installing Homebrew packages..."
    brew bundle Brewfile
    [[ $? ]] && echo "Done"
else
    printf "\n"
    echo "\nError: brew not found."
    printf "Install at http://brew.sh/\n"
    exit
fi

# update / install npm packages
# Check for npm
if [ `type -P npm` ]; then
    echo "Installing Node.js packages..."

    # List of npm packages
    packages="bower grunt-cli jshint yo"

    # Install packages globally and quietly
    npm install $packages --global --quiet

    [[ $? ]] && echo "Done"
else
    printf "\n"
    echo "Error: npm not found."
    printf "Aborting...\n"
    exit
fi
