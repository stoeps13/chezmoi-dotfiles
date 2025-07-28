#!/usr/bin/env bash

for i in davmail.service mbsync.service mbsync.timer syncthing.service vdirsync.timer chezmoi-init.service chezmoi-update.timer
do
        systemctl enable --user $i
done


