#!/usr/bin/bash

for i in  $(sudo virsh list --all | awk '/running/{print $2}' | grep -v kali); do
   sudo virsh shutdown "$i"
done

sleep 120

for j in  $(sudo virsh list --all | awk '/running/{print $2}' | grep -v kali); do
  sudo virsh destroy "$j" --graceful
done
