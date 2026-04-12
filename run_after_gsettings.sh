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

    # Set shortcuts
    # gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom900/']"
    # gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom900/ name 'Take and edit screenshot'
    # gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom900/ command 'flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE'
    # gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom900/ binding '<Super><Print>'
  else
    echo "Skip gsettings script, no gnome session detected!"
fi
