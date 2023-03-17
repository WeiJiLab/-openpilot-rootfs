#!/bin/bash

MNT_DIR='/mnt'

function mount_disk_image() {
    IMAGE_FILE="$1"
    sudo mount -o loop "${IMAGE_FILE}" "${MNT_DIR}"
}

function unmount_disk_image() {
    sudo umount "${MNT_DIR}"
}

function build_stage_3() {
    IMAGE_FILE=$1

    # mount target image
    mount_disk_image "${IMAGE_FILE}"

    # copy build scripts
    sudo cp -f ./install-package-for-stage-3.sh "${MNT_DIR}/install-package-for-stage-3.sh"
    sudo chmod 775 "${MNT_DIR}/install-package-for-stage-3.sh"

    # override original scripts to solve build issues
    sudo cp -f docker_scripts/SConstruct "${MNT_DIR}/root/openpilot"

    # Chroot to "${MNT_DIR}" & run setup scripts
    ./ch-mount.sh -m "${MNT_DIR}/" 'bash -c ./install-package-for-stage-3.sh'

    # Unmount "${MNT_DIR}"
    ./ch-mount.sh -u "${MNT_DIR}/"

    # unmount target image
    unmount_disk_image
}
