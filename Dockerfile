# ################## #
# ###### Base ###### #
# ################## #
FROM scratch AS ok8mp-forlinx-base
ADD ok8mp-rootfs-dockerbase.tar.gz /

# Use domestic source
RUN chmod 777 /tmp \
 && chmod 777 /dev/null
# && mv /etc/apt/sources.list /etc/apt/sources.list.official
COPY ./sources.list.ustc /etc/apt/sources.list

# Add new user 'lito'
# Change username and password
RUN useradd -s '/bin/bash' -m -G adm,sudo lito  \
 && echo "lito:lito" | chpasswd

# ######################################### #
# ###### Install Tools for OpenPilot ###### #
# ######################################### #

FROM ok8mp-forlinx-base AS ok8mp-install-openpilot-tools

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
WORKDIR /tmp
RUN mv scons_cache /data \
 && rm -rf ./*

# Finally turn to user lito
USER lito
