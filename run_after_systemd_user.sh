#!/usr/bin/env bash

for i in davmail.service  mbsync.timer syncthing.service vdirsync.timer ssh-agent.service
do
        systemctl enable --user $i
done

