# Easier navigation: ..
alias ..="cd .."

alias battery="acpi -V"

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias h="history"
alias j="jobs"

# Git
alias g="git"
alias gs="git status"
alias gpob='git push origin `git rev-parse --abbrev-ref HEAD`'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
  colorflag="--color"
else # OS X `ls`
  colorflag="-G"
fi

# List all files colorized in long format
alias l="ls -lF ${colorflag}"

# List all files colorized in long format, including dot files
alias la="ls -laF ${colorflag}"

# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
export LS_COLORS='no=00:fi=00:di=01;36:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# More usable PS processes
if [[ $OSTYPE == darwin* ]]; then
  alias ps='ps -ju `whoami`'
else
  alias ps='ps uf -U `whoami`'
fi;

alias screen='screen -RaAdaU'

# take a screenshot
alias screenshot="import -window root -crop 1920x1200+1680+0 -quality 100 ~/screenshot-\$(date +\"%F-%T\").png"

if [[ $OSTYPE == darwin* ]]; then
  # Get OS X Software Updates, and update installed Ruby gems, Homebrew,
  # npm, and their installed packages
  alias update='echo "Upgrading packages..." && cd ~ && sudo -v && brew update && brew upgrade && brew cask upgrade && brew cleanup && asdf plugin-update --all && sudo softwareupdate -i -a || echo "update Done!"'
else
  # Linux, use pacman
  alias update='sudo yaourt -Syyuc'
fi;

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias whatsmyip="ip"
alias localip="netstat -rn | grep default | head -n 1 | awk '{print \$6}' | xargs ipconfig getifaddr"

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

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
alias dotenv='export $(cat .env | xargs); cat .env'

# Simple python http server
alias httpserver="python3 -m http.server"

# GPG symmetric encrypt file (with just a password)
alias encsym='gpg --armor --symmetric --cipher-algo AES256'

# find yarn linked packages
alias linked="(ls -l node_modules/; ls -l node_modules/@*) | grep ^l"
