#!/bin/bash

lxc-stop -n Ubuntu
lxc-destroy -n Ubuntu
lxc-create -n Ubuntu -t ubuntu
lxc-start -n Ubuntu -d

while [ `lxc-info -n Ubuntu | grep IP: | sort | uniq | unexpand -a | cut -f3 | wc -l` -ne 1 ]; do
	sleep 1s
done

IP=`lxc-attach -n Ubuntu -- ifconfig | grep 'inet addr' | head -n 1 | cut -d ':' -f 2 | cut -d ' ' -f 1`

echo "IP: $IP:"

lxc-stop -n Ubuntu
