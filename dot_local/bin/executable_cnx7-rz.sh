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

for i in $(sudo virsh list --all | grep -e 'cnx-' | grep -v 'keycloak' | awk '/shut off/{print $2}')
do
  sudo virsh start $i
done

for i in $(sudo virsh list --all | grep -e 'cnx7' | grep -v 'sles' | awk '/shut off/{print $2}')
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
echo "  +++++ Starting Connections +++++"
echo
ssh root@cnx7-ihs.stoeps.home /appl/ihs/bin/apachectl -k start
ssh root@cnx7-ihs.stoeps.home /appl/ihs/bin/adminctl start
ssh root@cnx7-dmgr.stoeps.home /appl/was/Appserver/profiles/Dmgr01/bin/startManager.sh
ssh root@cnx7-cnx1.stoeps.home /appl/was/Appserver/profiles/AppSrv01/bin/startNode.sh
ssh root@cnx7-cnx2.stoeps.home /appl/was/Appserver/profiles/AppSrv01/bin/startNode.sh
ssh root@cnx7-docs1.stoeps.home /appl/was/Appserver/profiles/AppSrv01/bin/startNode.sh
ssh root@cnx7-docs2.stoeps.home /appl/was/Appserver/profiles/AppSrv01/bin/startNode.sh
echo
echo "  +++++ Restart Haproxy and nginx +++++"
echo
ssh root@cnx7.stoeps.home 'systemctl restart haproxy'
ssh root@cnx7.stoeps.home 'systemctl restart nginx'
