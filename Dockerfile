# ################## #
# ###### Base ###### #
# ################## #
FROM scratch AS ok8mp-ubuntu-base
ADD ubuntu-base-20.04.1-base-arm64.tar.gz /

# Stop on error
RUN set -xe

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

# Use domestic source
RUN mv /etc/apt/sources.list /etc/apt/sources.list.official
COPY ./sources.list.ustc /etc/apt/sources.list

# Locale setup
RUN apt-get update && apt-get install -y locales tzdata \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 \
 && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata

# ############################## #
# ###### Install Packages ###### #
# ############################## #

FROM ok8mp-ubuntu-base AS ok8mp-install-packages-6
RUN chmod 777 /tmp \
 && chmod 777 /dev/null \
 && apt-get update && apt-get install -y \
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

# Add new user 'lito'
# Change username and password
RUN useradd -s '/bin/bash' -m -G adm,sudo lito  \
 && echo "lito:lito" | chpasswd \
 && echo "root:lito" | chpasswd \
 && dpkg-reconfigure -f noninteractive resolvconf

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

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
	
# ############################# #
# ###### Install Wayland ###### #
# ############################# #

FROM ok8mp-install-packages-8 AS ok8mp-install-wayland

WORKDIR /tmp
RUN wget https://wayland.freedesktop.org/releases/wayland-1.18.0.tar.xz \
 && tar xf wayland-1.18.0.tar.xz
WORKDIR wayland-1.18.0
RUN ./configure --disable-documentation prefix=/usr \
 && make -j8 \
 && make install \
 && ldconfig
 
# ####################################### #
# ###### Install Wayland Protocols ###### #
# ####################################### #

FROM ok8mp-install-wayland AS ok8mp-install-wayland-protocols

WORKDIR /tmp
RUN git clone https://source.codeaurora.org/external/imx/wayland-protocols-imx.git
WORKDIR wayland-protocols-imx
RUN git checkout wayland-protocols-imx-1.18 \
 && ./autogen.sh --prefix=/usr \
 && make install \
 && ldconfig
	
# ############################ #
# ###### Install Weston ###### #
# ############################ #

FROM ok8mp-install-wayland-protocols AS ok8mp-install-weston

WORKDIR /tmp
RUN git clone https://source.codeaurora.org/external/imx/weston-imx.git
WORKDIR weston-imx
RUN git checkout weston-imx-8.0 \
 && meson build/ --prefix=/usr -Dbackend-default=auto -Dbackend-rdp=false -Dpipewire=false -Dsimple-clients=all -Ddemo-clients=true -Dcolor-management-colord=false -Drenderer-gl=true -Dbackend-fbdev=true -Drenderer-g2d=true -Dbackend-headless=false -Dimxgpu=true -Dbackend-drm=true -Dweston-launch=true -Dcolor-management-lcms=false -Dopengl=true -Dpam=true -Dremoting=false -Dsystemd=true -Dlauncher-logind=true -Dbackend-drm-screencast-vaapi=false -Dbackend-wayland=false -Dimage-webp=false -Dbackend-x11=false -Dxwayland=true 
WORKDIR build
RUN ninja -v -j 4 install

# ######################################### #
# ###### Install Tools for OpenPilot ###### #
# ######################################### #

FROM ok8mp-install-weston AS ok8mp-install-openpilot-tools

# Please refer to tools/update_ubuntu.sh to see what needs to be installed
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    ca-certificates \
    casync \
    clang \
    cmake \
    make \
    cppcheck \
    libtool \
    gcc-arm-none-eabi \
    bzip2 \
    liblzma-dev \
    libarchive-dev \
    libbz2-dev \
    capnproto \
    libcapnp-dev \
    curl \
    libcurl4-openssl-dev \
    git \
    git-lfs \
    ffmpeg \
    libavformat-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavutil-dev \
    libavfilter-dev \
    libeigen3-dev \
    libffi-dev \
    libglew-dev \
    libgles2-mesa-dev \
    libglfw3-dev \
    libglib2.0-0 \
    libomp-dev \
    libopencv-dev \
    libpng16-16 \
    libportaudio2 \
    libssl-dev \
    libsqlite3-dev \
    libusb-1.0-0-dev \
    libzmq3-dev \
    libsystemd-dev \
    locales \
    opencl-headers \
    ocl-icd-libopencl1 \
    ocl-icd-opencl-dev \
    clinfo \
    qml-module-qtquick2 \
    qtmultimedia5-dev \
    qtlocation5-dev \
    qtpositioning5-dev \
    qttools5-dev-tools \
    libqt5sql5-sqlite \
    libqt5svg5-dev \
    libqt5charts5-dev \
    libqt5x11extras5-dev \
    libreadline-dev \
    libdw1 \
    valgrind \
    libavresample-dev \
    qt5-default \
    python-dev

# ############################# #
# ###### Clone OpenPilot ###### #
# ############################# #

FROM ok8mp-install-openpilot-tools AS ok8mp-download-openpilot
USER lito
RUN git config --global user.name "lito" \
 && git config --global user.email "lito@163.com"
WORKDIR /data

# Clone source code
RUN git clone https://github.com/WeiJiLab/openpilot.git
WORKDIR openpilot
RUN git submodule update --init 
# RUN chmod u+x tools/ubuntu_setup.sh \
#  && tools/ubuntu_setup.sh
USER root
RUN chown -R lito:lito .
USER lito

# ############################################### #
# ###### Update Requirements for OpenPilot ###### #
# ############################################### #

FROM ok8mp-download-openpilot AS ok8mp-update-requirements

WORKDIR /data/openpilot

# The dependencies in pyproject.toml yields installation error on an ARM machine. We must replace pyproject.toml with a proper one.
# We also modify update_requirements.sh so that poetry does not create a virtual env. The docker container itself is already isolated.
# TODO: After revising the Weijilab/openpilot project accordingly, this step can be skipped.
RUN rm -f ./pyproject.toml ./poetry.lock ./update_requirements.sh
ADD --chown=lito:lito docker_scripts/pyproject.toml docker_scripts/poetry.lock docker_scripts/update_requirements.sh .
RUN ./update_requirements.sh
# Adding extra env-vars, which is duplicate work, already done on the last line '. ~/.pyenvrc' in /root/.bashrc
# RUN echo "\nsource /tmp/openpilot/tools/openpilot_env.sh" >> ~/.bashrc

# ############################# #
# ###### Build OpenPilot ###### #
# ############################# #

FROM ok8mp-update-requirements AS ok8mp-build-openpilot

WORKDIR /data/openpilot
RUN rm -f ./SConstruct
ADD --chown=lito:lito docker_scripts/build_openpilot.sh docker_scripts/SConstruct .
# Temporarily need root priviledge to create a symbolic link
USER root
RUN ln -s /home/lito/.pyenv/versions/3.8.10/lib/libpython3.8.so /usr/lib/aarch64-linux-gnu/libpython3.8.so
USER lito
RUN ./build_openpilot.sh

# ##################### #
# ###### Cleanup ###### #
# ##################### #

USER root

# Some extra installations
RUN apt-get update \
 && apt-get install tmux openssh-server

WORKDIR /tmp
RUN mv scons_cache /data \
 && rm -rf ./*

# Finally turn to user lito
USER lito
