#!/bin/bash

# Unpack rootfs & yocoto
rm -rf rootfs
mkdir rootfs build
tar -zxvf ubuntu-base-20.04.1-base-arm64.tar.gz -C rootfs
tar -zxvf yocoto.tar.gz


mv build rootfs
cp install_package.sh /rootfs

# Install qemu
sudo apt-get install -y qemu-user-static  

# Copy files
cp /usr/bin/qemu-aarch64-static rootfs/usr/bin   
cp -b /etc/resolv.conf rootfs/etc/   

# Chroot to rootfs
./ch-mount -m rootfs/


