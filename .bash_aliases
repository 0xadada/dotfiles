# Easier navigation: ..
alias ..="cd .."

alias battery="acpi -V"

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias h="history"

# Git
alias g="git"
alias gs="git status"
alias gpob='git push origin `git rev-parse --abbrev-ref HEAD`'

# List all files colorized in long format
alias l="ls -lF -G"
# List all files colorized in long format, including dot files
alias la="ls -laF -G"
# List only directories
alias lsd="ls -laFG | grep --color=always '^d'"

# Always use color output for `ls`
alias ls="command ls -G"

# Enable aliases to be sudo’ed
alias sudo='sudo '

alias screen='screen -RaAdaU'

# take a screenshot
alias screenshot="import -window root -crop 1920x1200+1680+0 -quality 100 ~/screenshot-\$(date +\"%F-%T\").png"

if [[ $OSTYPE == darwin* ]]; then
  # Get OS X Software Updates, and update installed Ruby gems, Homebrew,
  # npm, and their installed packages
  alias update='echo "Upgrading packages..." && cd ~ && sudo -v && sudo softwareupdate -i -a || brew update && brew upgrade && brew cleanup && asdf plugin-update --all || echo "update Done!"'
else
  # Linux, use pacman
  alias update='sudo yaourt -Syyuc'
fi;

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias whatsmyip="ip"
# shellcheck disable=SC2142
alias localip="netstat -rn | rg default | head -n1 | awk '{print \$4}' | xargs ipconfig getifaddr"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
# Also, run periodic maintenence tasks
alias emptytrash="echo Emptying trashes...; \
  sudo rm -rfv /Volumes/*/.Trashes; \
  sudo rm -rfv ~/.Trash; \
  echo Running all periodic maintenence tasks...; \
  sudo periodic daily weekly monthly; \
  echo Removing old logs...; \
  sudo rm -rfv /private/var/log/asl/*.asl; \
  sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 'delete from LSQuarantineEvent' >/dev/null 2>&1; \
  sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 'vacuum' >/dev/null 2>&1"

# Calculate current working directory size
alias cwdsize="du -sh ."

# Merge PDF files
# Usage: `mergepdf -o output.pdf input{1,2,3}.pdf`
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

# PlistBuddy alias, because sometimes `defaults` just doesn’t cut it
alias plistbuddy="/usr/libexec/PlistBuddy"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# source local .env file
alias dotenv='export $(cat .env | xargs); cat .env && echo 💫'

# Simple python http server
alias httpserver="python -m http.server"

# GPG symmetric encrypt file (with just a password)
alias encsym='gpg --armor --symmetric --cipher-algo AES256'

# find yarn linked packages
alias linked="(ls -l node_modules/; ls -l node_modules/@*) | grep ^l"

# show defaults domains broken by line break
alias defaultsdomains="defaults domains | sed -e 's/, /,/g' | tr ',' '\n'"

# be subtle about using neovim
alias vi="nvim --noplugins"
alias vim="echo '🚫 use nvim'"
