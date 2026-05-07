#!/usr/bin/env bash

for i in mbsync.service mbsync.timer syncthing.service vdirsync.service vdirsync.timer 
do
        systemctl enable --user $i
done


