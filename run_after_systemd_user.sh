#!/usr/bin/env bash

for i in davmail.service  mbsync.timer syncthing.service vdirsync.timer
do
        systemctl enable --user $i
done

