#!/usr/bin/env bash

sudo swapon /var/swapfile

# Check if libvirtd service is running
STATUS="$(sudo systemctl is-active libvirtd.service)"
if [ "${STATUS}" != "active" ]; then
	sudo systemctl start libvirtd
	sleep 3
	#sudo virsh net-start vm_network
    #sleep 5
	sudo systemctl start libvirt-guests
fi

# Check if network is active
if sudo virsh net-list --all | grep vm_network | grep inactive ; then
	sudo virsh net-start vm_network
fi

for i in $(sudo virsh list --all | grep -e 'cnx-' | awk '/shut off/{print $2}')
do
  sudo virsh start $i
done

#for i in $(sudo virsh list --all | grep -e 'cnx8-db2' | grep -v -e 'cnx8-db2-cp' | awk '/shut off/{print $2}')
for i in $(sudo virsh list --all | grep -e 'cnx8-db2' | awk '/shut off/{print $2}')
do
  sudo virsh start $i
done

echo
echo "  + Waiting for booting up all machines ..."
for k in {0..11}
do
    a=$((60 - $k*5))
    echo -e -n "\n  +++ waiting $a seconds    "
    for (( i=1; i<6; i++ ))
    do
        echo -n .
        sleep 1
    done
done

echo
# echo "  +++++ Starting Oracle database +++++"
# echo
# ssh oracle@cnx8-db2-db.stoeps.home /home/oracle/scripts/ora_start.sh
echo
echo "  +++++ Starting Connections +++++"
echo
ssh root@cnx8-db2-was.stoeps.home ./cnx-start.sh
echo
echo "  +++++ Restart Haproxy and nginx +++++"
echo
ssh root@cnx8-db2.stoeps.home 'systemctl restart haproxy'
ssh root@cnx8-db2.stoeps.home 'systemctl restart nginx'
echo
echo "  +++++ Start Keycloak +++++"
ssh root@cnx-keycloak.stoeps.home './kc-start.sh'