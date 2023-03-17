#!/bin/bash

MNT_DIR='/mnt'

function mount_disk_image() {
    IMAGE_FILE="$1"
    sudo mount -o loop "${IMAGE_FILE}" "${MNT_DIR}"
}

function unmount_disk_image() {
    sudo umount "${MNT_DIR}"
}

function build_stage_2() {
    IMAGE_FILE=$1

    # mount target image
    mount_disk_image "${IMAGE_FILE}"

    # copy scripts which used to setup env of openpilot
    sudo cp -rf ./openpilot "${MNT_DIR}/root/"

    # copy ubuntu-ports mirror source
    sudo mv -f "${MNT_DIR}/etc/apt/sources.list" "${MNT_DIR}/etc/apt/sources.list.official"
    sudo cp -f ./sources.list.ustc "${MNT_DIR}/etc/apt/sources.list"

    # copy install script
    sudo cp -f install-package-for-stage-2.sh "${MNT_DIR}/root"
    sudo chmod u+x "${MNT_DIR}/root/install-package-for-stage-2.sh"

    # override original poetry tomls to solve dependency issues
    sudo cp -f docker_scripts/pyproject.toml "${MNT_DIR}/root/openpilot/"
    sudo cp -f docker_scripts/poetry.lock "${MNT_DIR}/root/openpilot/"
    sudo cp -f docker_scripts/update_requirements.sh "${MNT_DIR}/root/openpilot/"

    # Chroot to "${MNT_DIR}" & run setup scripts
    ./ch-mount.sh -m "${MNT_DIR}/" '/root/install-package-for-stage-2.sh'

    # Unmount "${MNT_DIR}"
    ./ch-mount.sh -u "${MNT_DIR}/"

    # clean disk
    sudo apt-get clean
    sudo rm -f "${MNT_DIR}/etc/apt/sources.list"
    sudo mv -f "${MNT_DIR}/etc/apt/sources.list.official" "${MNT_DIR}/etc/apt/sources.list"
    sudo rm -f "${MNT_DIR}/root/install-package-for-stage-2.sh";

    # unmount target image
    unmount_disk_image

    # clean host
    rm -rf './openpilot'
}
