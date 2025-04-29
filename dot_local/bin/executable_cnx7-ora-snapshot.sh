#!/usr/bin/env bash

# Check if libvirtd service is running
STATUS="$(sudo systemctl is-active libvirtd.service)"
if [ "${STATUS}" != "active" ]; then
	sudo systemctl start libvirtd
	sleep 3
	sudo virsh net-start vm_network
    sleep 5
	sudo systemctl start libvirt-guests
fi

# Check if network is active
if sudo virsh net-list --all | grep vm_network | grep inactive ; then
	sudo virsh net-start vm_network
fi

DATE=$(date '+%Y-%m-%d')

for i in $(sudo virsh list --all | grep -e 'cnx7-ora' | awk '{print $2}')
do
  sudo virsh snapshot-create-as --domain $i --name ${i}_snapshot_${DATE} --description "Snapshot before starting Harbor tests"
done

