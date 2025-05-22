#!/usr/bin/env bash
# fail with rc 0 when flatpak is not installed
type flatpak >/dev/null 2>&1 || exit 0

# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo -u
flatpak install org.keystore_explorer.KeyStoreExplorer -y
# flatpak install -u flathub com.bitwarden.desktop -y
# flatpak install -u flathub com.calibre_ebook.calibre -y
# flatpak install -u flathub com.discordapp.Discord -y
# flatpak install -u flathub com.github.micahflee.torbrowser-launcher -y
# flatpak install -u flathub com.github.tchx84.Flatseal -y
# flatpak install -u flathub com.google.Chrome -y
# flatpak install -u flathub com.jgraph.drawio.desktop -y
# flatpak install -u flathub com.mattjakeman.ExtensionManager -y
# flatpak install -u flathub io.dbeaver.DBeaverCommunity -y
# flatpak install -u flathub io.github.java_decompiler.jd-gui -y
# flatpak install -u flathub io.podman_desktop.PodmanDesktop -y
# flatpak install -u flathub org.blender.Blender -y
# flatpak install -u flathub org.cryptomator.Cryptomator -y
# flatpak install -u flathub org.davmail.DavMail -y
# flatpak install -u flathub org.gimp.GIMP -y
# flatpak install -u flathub org.gnome.meld -y
# flatpak install -u flathub org.inkscape.Inkscape -y
# flatpak install -u flathub org.libreoffice.LibreOffice -y
# flatpak install -u flathub org.localsend.localsend_app -y
# flatpak install -u flathub org.mozilla.firefox -y
# flatpak install -u flathub us.zoom.Zoom -y
