#!/bin/bash
set -x

function build_stage_2() {
#    # clone openpilot
#    # need add following lines to ~/.ssh/config
#    #   Host github.com
#    #       AddKeysToAgent yes
#    #       StrictHostKeyChecking no
#    #       IdentityFile ~/.ssh/id_rsa
#    if [ -d './openpilot' ]; then
#        rm -rf './openpilot'
#    fi
#    git clone git@github.com:WeiJiLab/openpilot.git
#    if [ "$?" != "0" ]; then
#        exit 1
#    fi
#
#    # copy scripts which used to setup env of openpilot
#    mkdir -p rootfs/openpilot
#    cp -r openpilot/tools rootfs/openpilot/
#    chmod u+x rootfs/openpilot/tools/*.sh
#    cp openpilot/update_requirements.sh rootfs/openpilot/
#    chmod u+x rootfs/openpilot/update_requirements.sh
#    cp openpilot/pyproject.toml rootfs/openpilot/
#    cp openpilot/.python-version rootfs/openpilot/
#
#    # copy ubuntu-ports mirror source
#    mv rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.official
#    cp -f ./sources.list.ustc rootfs/etc/apt/sources.list
#
#    # Chroot to rootfs & run setup scripts
#    ./ch-mount.sh -m rootfs/ '/root/install_package.sh'
#
#    # Unmount rootfs
#    ./ch-mount.sh -u rootfs/
}
