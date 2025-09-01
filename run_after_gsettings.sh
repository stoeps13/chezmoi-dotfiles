#!/usr/bin/env bash

type gsettings >/dev/null 2>&1 || exit 0

# Disable Nautilus recent files
gsettings set org.gnome.desktop.privacy remember-recent-files false

# Set compose key
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none', 'eurosign:e', 'compose:rctrl', 'caps:ctrl_modifier']"

# Set touchpad tap to click
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Switch workspace on all displays
gsettings set org.gnome.mutter workspaces-only-on-primary false
