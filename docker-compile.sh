#!/bin/bash

cd /home/ubuntu
echo "Installing base dependencies . . ."

sudo apt-get update
sudo apt-get -y install aufs-tools automake btrfs-tools build-essential \
			curl dpkg-sig git iptables libapparmor-dev libcap-dev \
			libsqlite3-dev lxc mercurial parallel reprepro ruby1.9.1 \
			ruby1.9.1-dev pkg-config libpcre* nano \
			--no-install-recommends

echo "Compiling Go . . ."
hg clone -u release https://code.google.com/p/go ./p/go
cd ./p/go/src
./all.bash
cd ../../../

export GOPATH=$(pwd)/go
export PATH=$GOPATH/bin:$PATH:$(pwd)/p/go/bin
export AUTO_GOPATH=1


echo "Compiling lvm2 . . ."
git clone https://git.fedorahosted.org/git/lvm2.git
cd lvm2
(git checkout -q v2_02_103 && ./configure --enable-static_link && make device-mapper && make install_device-mapper && echo lvm build OK!) || (echo lvm2 build failed && exit 1)
cd ..


echo "Compiling Docker . . ."
#git clone https://github.com/docker/docker $GOPATH/src/github.com/docker/docker

for f in `grep -r "if runtime.GOARCH \!\= \"amd64\" {" $GOPATH/src/* | cut -d: -f1`; do
	echo "Patching $f"
	sed -i 's/if runtime.GOARCH != "amd64" {/if runtime.GOARCH != "amd64" \&\& runtime.GOARCH != "386" {/g' $f
done


cd $GOPATH/src/github.com/docker/docker/
./hack/make.sh binary
cd ../../../../../

cd go/src/github.com/docker/docker/bundles/
tar cvfz /home/ubuntu/docker-bundle.tar.gz *
