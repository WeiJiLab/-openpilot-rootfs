#!/bin/bash
set -x

echo '## Start to install packages ################################'

chmod 777 /tmp /dev/null

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Install Base Package
apt-get update --fix-missing
apt-get install -y language-pack-en-base sudo ssh net-tools network-manager iputils-ping rsyslog bash-completion htop resolvconf dialog vim udhcpc udhcpd git v4l-utils alsa-utils git gcc less autoconf autopoint libtool bison flex gtk-doc-tools libglib2.0-dev libpango1.0-dev libatk1.0-dev kmod pciutils libjpeg-dev netplan.io
if [ "$?" != "0" ]; then
    echo "failed to install system tools with apt"
    exit 1
fi

# Change Passwd
useradd -s '/bin/bash' -m -G adm,sudo lito
if [ "$?" != "0" ]; then
    echo 'failed to add user: -m -G adm,sudo lito'
    exit 1
fi

echo "lito" | passwd --stdin lito
echo "lito" | passwd --stdin root

# Set Hostname
echo 'ubuntu20' > /etc/hostname
dpkg-reconfigure resolvconf
if [ "$?" != "0" ]; then
    echo "failed to execute 'dpkg-reconfigure resolvconf'"
    exit 1
fi

# Config Serial Port
cp -Pra /build/imx8qmmek-poky-linux/systemd-serialgetty/1.0-r5/image/etc/* /etc
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/imx8qmmek-poky-linux/systemd-serialgetty/1.0-r5/image/etc/* to /etc'
    exit 1
fi

cp -Pra /build/imx8qmmek-poky-linux/systemd-serialgetty/1.0-r5/image/lib/* /usr/lib
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/imx8qmmek-poky-linux/systemd-serialgetty/1.0-r5/image/lib/* to /usr/lib'
    exit 1
fi

# Build Weston
rm -rf /usr/lib/aarch64-linux-gnu/libdrm*
rm -rf /usr/lib/aarch64-linux-gnu/mesa-egl*
rm -rf /usr/lib/aarch64-linux-gnu/libglapi.so.0*
rm -rf /usr/lib/aarch64-linux-gnu/libwayland-*

cp -Pra /build/aarch64-mx8-poky-linux/libdrm/2.4.102.imx-r0/image/* /
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/aarch64-mx8-poky-linux/libdrm/2.4.102.imx-r0/image/* to /'
    exit 1
fi

cp -Pra /build/aarch64-mx8-poky-linux/imx-gpu-viv/1_6.4.3.p1.0-aarch64-r0/image/* /
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/aarch64-mx8-poky-linux/imx-gpu-viv/1_6.4.3.p1.0-aarch64-r0/image/* to /'
    exit 1
fi

cp -Pra /build/aarch64-mx8-poky-linux/imx-dpu-g2d/1.8.12-r0/image/* /
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/aarch64-mx8-poky-linux/imx-dpu-g2d/1.8.12-r0/image/* to /'
    exit 1
fi

cp -Pra /build/aarch64-mx8-poky-linux/linux-imx-headers/5.4-r0/image/*  /
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/aarch64-mx8-poky-linux/linux-imx-headers/5.4-r0/image/* to /'
    exit 1
fi

cp -Pra /build/aarch64-poky-linux/imx-parser/4.5.7-r0/image/*  /
if [ "$?" != "0" ]; then
    echo '* failed to copy /build/aarch64-poky-linux/imx-parser/4.5.7-r0/image/* to /'
    exit 1
fi

apt-get install -y libudev-dev libinput-dev libxkbcommon-dev libpam0g-dev libx11-xcb-dev libxcb-xfixes0-dev libxcb-composite0-dev libxcursor-dev libxcb-shape0-dev libdbus-1-dev libdbus-glib-1-dev libsystemd-dev libpixman-1-dev libcairo2-dev libffi-dev libxml2-dev kbd libexpat1-dev autoconf automake libtool meson cmake
if [ "$?" != "0" ]; then
    echo 'failed to install some dependencies with apt'
    exit 1
fi

# Version 1 rootfs
cd /root/wayland-1.18.0/
./configure --disable-documentation prefix=/usr
if [ "$?" != "0" ]; then
    echo 'failed to run configure for disable documentation'
    exit 1
fi

make -j8 && make install && ldconfig
if [ "$?" != "0" ]; then
    echo "failed to execute 'make -j8 && make install && ldconfig'"
    exit 1
fi

# Version 2 rootfs
cd /root/wayland-protocols-imx

./autogen.sh --prefix=/usr
if [ "$?" != "0" ]; then
    echo 'failed to run autogen.sh'
    exit 1
fi

make install && ldconfig
if [ "$?" != "0" ]; then
    echo "failed to execute 'make install && ldconfig'"
    exit 1
fi

# Version 3 rootfs
cd /root/weston-imx
meson build/ --prefix=/usr -Dbackend-default=auto -Dbackend-rdp=false -Dpipewire=false -Dsimple-clients=all -Ddemo-clients=true -Dcolor-management-colord=false -Drenderer-gl=true -Dbackend-fbdev=true -Drenderer-g2d=true -Dbackend-headless=false -Dimxgpu=true -Dbackend-drm=true -Dweston-launch=true -Dcolor-management-lcms=false -Dopengl=true -Dpam=true -Dremoting=false -Dsystemd=true -Dlauncher-logind=true -Dbackend-drm-screencast-vaapi=false -Dbackend-wayland=false -Dimage-webp=false -Dbackend-x11=false -Dxwayland=true
if [ "$?" != "0" ]; then
    echo 'failed to run meson build'
    exit 1
fi

cd build && ninja -v -j 12 install
if [ "$?" != "0" ]; then
    echo "failed to execute 'ninja -v -j 12 install'"
    exit 1
fi
echo '## Finished to install packages ################################'

exit 0