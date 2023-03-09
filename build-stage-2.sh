#!/bin/bash
set -x

MNT_DIR='/mnt'

function mount_disk_image() {
    IMAGE_FILE=$1
    sudo mount -o loop "${IMAGE_FILE}" "${MNT_DIR}"
}

function unmount_disk_image() {
    sudo umount "${MNT_DIR}"
}

function build_stage_2() {
    IMAGE_FILE=$1
    mount_disk_image "${IMAGE_FILE}"

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

    # copy scripts which used to setup env of openpilot
    sudo mkdir -p "${MNT_DIR}/openpilot"
    sudo cp -r openpilot/tools "${MNT_DIR}/openpilot/"
    sudo chmod u+x "${MNT_DIR}/openpilot/tools/*.sh"
    sudo cp openpilot/update_requirements.sh "${MNT_DIR}/openpilot/"
    sudo chmod u+x "${MNT_DIR}/openpilot/update_requirements.sh"
    sudo cp openpilot/pyproject.toml "${MNT_DIR}/openpilot/"
    sudo cp openpilot/.python-version "${MNT_DIR}/openpilot/"

    # copy ubuntu-ports mirror source
    sudo mv -f "${MNT_DIR}/etc/apt/sources.list" "${MNT_DIR}/etc/apt/sources.list.official"
    sudo cp -f ./sources.list.ustc "${MNT_DIR}/etc/apt/sources.list"

    # copy install script
    sudo cp install-package-for-stage-2.sh "${MNT_DIR}/root"
    sudo chmod u+x "${MNT_DIR}/root/install-package-for-stage-2.sh"

    # Chroot to "${MNT_DIR}" & run setup scripts
    ./ch-mount.sh -m "${MNT_DIR}/" '/root/install-package-for-stage-2.sh'

    # Unmount "${MNT_DIR}"
    ./ch-mount.sh -u "${MNT_DIR}/"

    # clean disk
    sudo apt-get clean
    sudo rm -rf "${MNT_DIR}/openpilot"
    sudo rm -f "${MNT_DIR}/etc/apt/sources.list"
    sudo mv -f "${MNT_DIR}/etc/apt/sources.list.official" "${MNT_DIR}/etc/apt/sources.list"

    unmount_disk_image

    # clean host
    rm -rf './openpilot'
}
