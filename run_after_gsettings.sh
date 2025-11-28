#!/usr/bin/env bash

# echo "Desktop session: $DESKTOP_SESSION"

if [[ $DESKTOP_SESSION = "gnome" ]]
  then
    echo "Gnome session detected"
    type gsettings >/dev/null 2>&1 || exit 0
    
    # Disable Nautilus recent files
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    
    # Set compose key
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none', 'eurosign:e', 'compose:rctrl', 'caps:ctrl_modifier']"
    
    # Set touchpad tap to click
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    
    # Switch workspace on all displays
    gsettings set org.gnome.mutter workspaces-only-on-primary false
  else
    echo "Skip gsettings script, no gnome session detected!"
fi
