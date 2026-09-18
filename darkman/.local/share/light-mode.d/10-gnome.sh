#!/bin/sh
# GNOME / GTK colour scheme. gtk-theme is set alongside color-scheme because
# legacy GTK3 apps ignore the latter; libadwaita apps follow color-scheme.
# Run by darkman on the light transition.
set -eu

gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
