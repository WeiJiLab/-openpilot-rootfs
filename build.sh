#!/bin/bash

# clone openpilot
# need add following lines to ~/.ssh/config
#   Host github.com
#       AddKeysToAgent yes
#       StrictHostKeyChecking no
#       IdentityFile ~/.ssh/id_rsa
if [ -d './openpilot' ]; then
    rm -rf './openpilot'
fi
git clone git@github.com:WeiJiLab/openpilot.git
if [ "$?" != "0" ]; then
    exit 1
fi

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
chmod u+x rootfs/root/install_package.sh

# copy scripts which used to setup env of openpilot
mkdir -p rootfs/openpilot
cp -r openpilot/tools rootfs/openpilot/
chmod u+x rootfs/openpilot/tools/*.sh
cp openpilot/update_requirements.sh rootfs/openpilot/
chmod u+x rootfs/openpilot/update_requirements.sh
cp openpilot/pyproject.toml rootfs/openpilot/
cp openpilot/.python-version rootfs/openpilot/

cp -r wayland-1.18.0 rootfs/root
cp -r wayland-protocols-imx rootfs/root
cp -r weston-imx rootfs/root

# Chroot to rootfs & run setup scripts
./ch-mount.sh -m rootfs/ '/root/install_package.sh && cd openpilot && ./tools/ubuntu_setup.sh && cd .. && rm -rf ./openpilot && exit'

# Unmount rootfs
./ch-mount.sh -u rootfs/
