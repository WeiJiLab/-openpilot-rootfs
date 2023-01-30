#!/bin/bash

# Unpack rootfs & yocoto
rm -rf rootfs
mkdir rootfs build
tar -zxvf ubuntu-base-20.04.1-base-arm64.tar.gz -C rootfs
tar -zxvf yocoto.tar.gz

# Install qemu
sudo apt-get install -y qemu-user-static  

# Copy files
mv build rootfs
cp /usr/bin/qemu-aarch64-static rootfs/usr/bin   
cp -b /etc/resolv.conf rootfs/etc/   

cp install_package.sh rootfs/root
cp -r wayland-1.18.0 rootfs/root
cp -r wayland-protocols-imx rootfs/root
cp -r weston-imx rootfs/root

# Chroot to rootfs
./ch-mount.sh -m rootfs/

# Unmount rootfs
./ch-mount.sh -u rootfs/
