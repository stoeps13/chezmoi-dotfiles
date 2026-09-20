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

    # Enable Middle mouse button paste
    gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true

    # Enable Logout menu entry
    gsettings set org.gnome.shell always-show-log-out true

    # Bind Shift+Super+S to Wayshot capture
    wayshot_keybinding="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wayshot/"
    custom_keybindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    if [[ $custom_keybindings != *"$wayshot_keybinding"* ]]; then
      custom_keybindings=${custom_keybindings#@as }
      custom_keybindings=${custom_keybindings%]}
      if [[ $custom_keybindings = "[" ]]; then
        custom_keybindings="['$wayshot_keybinding']"
      else
        custom_keybindings="$custom_keybindings, '$wayshot_keybinding']"
      fi
      gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$custom_keybindings"
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$wayshot_keybinding name "Wayshot capture"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$wayshot_keybinding command "flatpak run --env=WAYSHOT_CAPTURE=1 io.github.gutopardini.wayshot"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$wayshot_keybinding binding "<Shift><Super>s"

  else
    echo "Skip gsettings script, no gnome session detected!"
fi
