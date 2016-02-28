# Merge custom Xresources with globals
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# Start the window manager
exec awesome
