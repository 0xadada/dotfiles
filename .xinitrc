# Merge custom Xresources with globals
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

if [ `type -P xcalib` ]; then
    # Use a basic color profile
    xcalib ~/.colorprofiles/MacBookPro7\,1-Color-LCD8DD3C7B2-39C2-BCC4-E3C0-DB1AADED70FC.icc
fi;

if [ `type -P xbindkeys` ]; then
    # Load custom keyboard key bindings
    xbindkeys
fi;

# Start the window manager
exec awesome
