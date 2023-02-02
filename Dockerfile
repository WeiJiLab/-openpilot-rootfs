# ################## #
# ###### Base ###### #
# ################## #
FROM scratch AS ok8mp-ubuntu-base
ADD ubuntu-base-20.04.1-base-arm64.tar.gz /

# Stop on error
RUN set -xe

# Build folder
# RUN mkdir -p /tmp/ok8mp

# ENV USERNAME=comma
# ENV PASSWD=comma
# ENV HOST=tici

# Base system setup
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

# In the build_via_docker.sh file we have already installed qemu
# Copy qemu into the container
# COPY /usr/bin/qemu-aarch64-static /usr/bin
# COPY /etc/resolv.conf /etc

# Set the locales
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8
ENV TZ Asia/Shanghai
RUN apt-get update && apt-get install -y locales # systemd

# Locale setup
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
# RUN timedatectl set-timezone Asia/Shanghai

# Disable interative
ENV DEBIAN_FRONTEND noninteractive

# ############################## #
# ###### Install Packages ###### #
# ############################## #

FROM ok8mp-ubuntu-base AS ok8mp-install-packages-6
RUN chmod 777 /tmp
RUN chmod 777 /dev/null
RUN apt-get update && apt-get install -y \
	language-pack-en-base \
	sudo \
	ssh \
	net-tools \
	network-manager \
	iputils-ping \
	rsyslog \
	bash-completion \
	htop \
	resolvconf \
	dialog \
	vim \
	udhcpc \
	udhcpd \
	git \
	v4l-utils \
	alsa-utils \
#	git \
	gcc \
	less \
	autoconf \
	autopoint \
	libtool \
	bison \
	flex \
	gtk-doc-tools \
	libglib2.0-dev \
	libpango1.0-dev \
	libatk1.0-dev \
	kmod \
	pciutils \
	libjpeg-dev \
	netplan.io

FROM ok8mp-install-packages-6 AS ok8mp-install-packages-6-3

# Change Passwd
RUN useradd -s '/bin/bash' -m -G adm,sudo lito  \
 && chpasswd "lito:lito" \
 && chpasswd "root:lito" \

# Set Hostname
 && sh -c 'echo "ubuntu20" > /etc/hostname' \
 && dpkg-reconfigure resolvconf

FROM ok8mp-install-packages-6-3 AS ok8mp-install-packages-7

ADD yocoto.tar.gz /tmp

# Config Serial Port
RUN cp -Pra /tmp/build/imx8qmmek-poky-linux/systemd-serialgetty/1.0-r5/image/etc/* /etc \
 && cp -Pra /tmp/build/imx8qmmek-poky-linux/systemd-serialgetty/1.0-r5/image/lib/* /usr/lib \

# Build Weston
 && rm -rf /usr/lib/aarch64-linux-gnu/libdrm* \
 && rm -rf /usr/lib/aarch64-linux-gnu/mesa-egl* \
 && rm -rf /usr/lib/aarch64-linux-gnu/libglapi.so.0* \ 
 && rm -rf /usr/lib/aarch64-linux-gnu/libwayland-* \


 && cp -Pra /tmp/build/aarch64-mx8-poky-linux/libdrm/2.4.102.imx-r0/image/* / \
 && cp -Pra /tmp/build/aarch64-mx8-poky-linux/imx-gpu-viv/1_6.4.3.p1.0-aarch64-r0/image/* / \
 && cp -Pra /tmp/build/aarch64-mx8-poky-linux/imx-dpu-g2d/1.8.12-r0/image/* / \
 && cp -Pra /tmp/build/aarch64-mx8-poky-linux/linux-imx-headers/5.4-r0/image/*  / \
 && cp -Pra /tmp/build/aarch64-poky-linux/imx-parser/4.5.7-r0/image/*  /

FROM ok8mp-install-packages-7 AS ok8mp-install-packages-8

RUN apt-get update && apt-get install -y \
	libudev-dev \
	libinput-dev \
	libxkbcommon-dev \
	libpam0g-dev \
	libx11-xcb-dev \
	libxcb-xfixes0-dev \
	libxcb-composite0-dev \
	libxcursor-dev \
	libxcb-shape0-dev \
	libdbus-1-dev \
	libdbus-glib-1-dev \
	libsystemd-dev \
	libpixman-1-dev \
	libcairo2-dev \
	libffi-dev \
	libxml2-dev \
	kbd \
	libexpat1-dev \
	autoconf \
	automake \
	libtool \
	meson \
	cmake
	
# ############################ #
# ###### Install Weston ###### #
# ############################ #

FROM ok8mp-install-packages-8 AS ok8mp-install-weston

WORKDIR /tmp
RUN git clone https://source.codeaurora.org/external/imx/weston-imx.git
WORKDIR weston-imx

