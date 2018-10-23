#! /usr/bin/fish

/usr/bin/env XLIB_SKIP_ARGB_VISUALS=1 XMODIFIERS= /usr/bin/emacs --daemon

notify-send -i emacs "GNU Emacs daemon started!"

# ⌘ + D          ~/bin/start-emacs-deamon.fish
# ⌘ + E          emacsclient -c

