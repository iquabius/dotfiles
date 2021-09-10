#! /usr/bin/fish

# Empty XMODIFIERS is needed to fix "<dead_tilde> is undefined" on Ubuntu
# https://www.emacswiki.org/emacs/DeadKeys
/usr/bin/env XLIB_SKIP_ARGB_VISUALS=1 XMODIFIERS= /usr/bin/emacs --daemon

notify-send -i emacs "GNU Emacs daemon started!"

# ⌘ + D          ~/bin/start-emacs-deamon.fish
# ⌘ + E          emacsclient -c

# Idea: https://stackoverflow.com/questions/5570451/how-to-start-emacs-server-only-if-it-is-not-started
