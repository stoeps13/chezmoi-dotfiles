#!/usr/bin/env bash

pkgs=(alacritty bat bc bitwarden-cli cargo chezmoi chromium curl dbeaver difftastic discord distrobox eza fastfetch fd ffmpeg fish fish-autopair fish-pure-prompt fisher flatpak fractal fzf gimp go htop hugo imagemagick isync jq just khal khard kitty mise msmtp neomutt neovim obs-studio python-six python-tasklib python-tzlocal python-urllib3 python-yaml python-yarl qemu-audio-alsa qemu-audio-dbus qemu-audio-jack qemu-audio-oss qemu-audio-pa qemu-audio-pipewire qemu-audio-sdl qemu-audio-spice qemu-base qemu-block-curl qemu-block-dmg qemu-block-gluster qemu-block-iscsi qemu-block-nfs qemu-block-ssh qemu-chardev-baum qemu-chardev-spice qemu-common qemu-desktop qemu-docs qemu-emulators-full qemu-full qemu-hw-display-qxl qemu-hw-display-virtio-gpu qemu-hw-display-virtio-gpu-gl qemu-hw-display-virtio-gpu-pci qemu-hw-display-virtio-gpu-pci-gl qemu-hw-display-virtio-gpu-pci-rutabaga qemu-hw-display-virtio-gpu-rutabaga qemu-hw-display-virtio-vga qemu-hw-display-virtio-vga-gl qemu-hw-display-virtio-vga-rutabaga qemu-hw-s390x-virtio-gpu-ccw qemu-hw-uefi-vars qemu-hw-usb-host qemu-hw-usb-redirect qemu-hw-usb-smartcard qemu-img qemu-pr-helper qemu-system-aarch64 qemu-system-alpha qemu-system-alpha-firmware qemu-system-arm qemu-system-arm-firmware qemu-system-avr qemu-system-hppa qemu-system-hppa-firmware qemu-system-loongarch64 qemu-system-m68k qemu-system-microblaze qemu-system-microblaze-firmware qemu-system-mips qemu-system-or1k qemu-system-ppc qemu-system-ppc-firmware qemu-system-riscv qemu-system-riscv-firmware qemu-system-rx qemu-system-s390x qemu-system-s390x-firmware qemu-system-sh4 qemu-system-sparc qemu-system-sparc-firmware qemu-system-tricore qemu-system-x86 qemu-system-x86-firmware qemu-system-xtensa qemu-tests qemu-tools qemu-ui-curses qemu-ui-dbus qemu-ui-egl-headless qemu-ui-gtk qemu-ui-opengl qemu-ui-sdl qemu-ui-spice-app qemu-ui-spice-core qemu-user qemu-vhost-user-gpu qemu-vmsr-helper qrencode raptor ripgrep rsync sed shellcheck syncthing task the_silver_searcher tmux tree-sitter tree-sitter-c tree-sitter-cli tree-sitter-lua tree-sitter-markdown tree-sitter-query tree-sitter-vim tree-sitter-vimdoc vale vdirsyncer vim virt-install virt-manager virt-viewer wl-clipboard yaml-language-server yarn yay zen-browser-bin zoxide ttf-roboto adobe-source-sans-fonts w3m pandoc gnome-shell-extension-dash-to-dock gnome-shell-extension-vitals gnome-shell-extension-weather-oclock libinput-tools pika-backup signal-desktop ttf-roboto adobe-source-sans-fonts)

pkgs_yay=(davmail taskopen virtnbdbackup syncthingtray jd-gui-bin difft gnome-shell-extension-gradia-capture-git)
#
# Installing packages
sudo pacman -Sy "${pkgs[@]}"

# Installing AUR packages
yay -Sy "${pkgs_yay[@]}"

fisher install IlanCosman/tide@v6

