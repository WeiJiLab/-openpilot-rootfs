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
RUN useradd -s '/bin/bash' -m -G adm,sudo lito  
RUN chpasswd "lito:lito"
RUN chpasswd "root:lito"

# Set Hostname
RUN sh -c 'echo "ubuntu20" > /etc/hostname'
RUN dpkg-reconfigure resolvconf

FROM ok8mp-install-packages-6-3 AS ok8mp-install-packages-7
