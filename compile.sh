#!/bin/bash

echo -n "Rebuild Docker build environment (Y/N)? "
read REPLY

case "$REPLY" in
	Y|y)
		echo "Rebuilding Docker build environment . . ."
		/bin/bash rebuild.sh
		;;
	N|n|*)
		echo "Not rebuilding Docker build environment"
		;;
esac


lxc-stop -n Ubuntu
lxc-start -n Ubuntu -d

while [ `lxc-info -n Ubuntu | grep IP: | sort | uniq | unexpand -a | cut -f3 | wc -l` -ne 1 ]; do
	sleep 1s
done

IP=`lxc-attach -n Ubuntu -- ifconfig | grep 'inet addr' | head -n 1 | cut -d ':' -f 2 | cut -d ' ' -f 1`

echo "IP: $IP"


scp ./docker-compile.sh ubuntu@$IP:/home/ubuntu
while [ $? -ne 0 ]; do
	sleep 1s
	scp ./docker-compile.sh ubuntu@$IP:/home/ubuntu
done

lxc-attach -n Ubuntu '/home/ubuntu/docker-compile.sh'


scp ubuntu@$IP:/home/ubuntu/docker-bundle.tar.gz ./
lxc-stop -n Ubuntu
tar xvfz docker-bundle.tar.gz
