#!/usr/bin/env bash

for i in mbsync.timer syncthing.service vdirsync.timer rss-to-readeck.timer
do
        systemctl enable --user $i
done


