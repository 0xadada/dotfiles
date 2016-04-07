# Load the shell dotfiles, and then some:
# * ~/.bash_custom can be used for other settings you don’t want to commit.
for file in ~/.{bash_prompt,bash_exports,bash_aliases,bash_custom}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Load the high-color (more than 256) gruvbox colors
[ -e ~/.vim/bundle/gruvbox/gruvbox_256palette.sh ] && \
    source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"
# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history"
# Useful timestamp format
HISTTIMEFORMAT='%F %T '

# After each command, append to the history file and reread it
# Note: Enables shared history amongst multiple terminals.
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Save multi-line commands as one command
shopt -s cmdhist

# Update window size after each command
shopt -s checkwinsize

# Enable some Bash 4 features when possible:
# * `autocd`, Automatic cd into named-direcotryi e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * `globstar` Recursive globbing, e.g. `echo **/*.txt`
# * `dirspell` Correct spelling mistakes during tab-completion
for option in autocd dirspell globstar; do
    shopt -s "$option" 2> /dev/null
done

# Perform file completion in a case insensitive fashion
bind "set completion-ignore-case on"
# Treat hyphens and underscores as equivalent
bind "set completion-map-case on"
# Display matches for ambiguous patterns at first tab press
bind "set show-all-if-ambiguous on"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" \
    -o "nospace" \
    -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" \
    scp sftp ssh

if [[ $OSTYPE == darwin* ]]; then
    # Add tab completion for `defaults read|write NSGlobalDomain`
    # You could just use `-g` instead, but I like being explicit
    complete -W "NSGlobalDomain" defaults

    # Add `killall` tab completion for common apps
    complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
fi

# If possible, add tab completion for many more commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# Run SSH-agent (if it's not already running)
if ! pgrep -u $USER ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh-agent-pid
fi
# Add SSH to the shell
[ -e ~/.ssh-agent-pid ] && eval $(<~/.ssh-agent-pid) > /dev/null
# Add SSH identities to the agent (if they haven't been added)
if ! ssh-add -l > /dev/null; then
    echo "Add SSH identity to ssh-agent:"
    ssh-add
fi
