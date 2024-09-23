#!/usr/bin/env bash

# Disable Nautilus recent files
gsettings set org.gnome.desktop.privacy remember-recent-files false

# Set compose key
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none', 'eurosign:e', 'compose:rctrl']"

# Set touchpad tap to click
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
