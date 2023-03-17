#!/bin/bash

MNT_DIR='/mnt'

function create_disk_img_and_mount() {
    IMAGE_FILE=$1
    IMAGE_BLOCK_COUNT=$2

    PARENT_FOLDER_PATH=$(dirname "${IMAGE_FILE}")
    if [ ! -d "${PARENT_FOLDER_PATH}" ]; then
        mkdir -p "${PARENT_FOLDER_PATH}"
    fi

    if [ -f "${IMAGE_FILE}" ]; then
        rm -f "${IMAGE_FILE}"
    fi

    dd if=/dev/zero of="${IMAGE_FILE}" bs=1M count=${IMAGE_BLOCK_COUNT}
    mkfs.ext4 "${IMAGE_FILE}"
    sudo mount -o loop "${IMAGE_FILE}" "${MNT_DIR}"
}

function umount_disk_image() {
    sudo umount "${MNT_DIR}"
}

function build_stage_1() {
    IMAGE_FILE=$1
    IMAGE_BLOCK_COUNT=$2

    create_disk_img_and_mount "${IMAGE_FILE}" "${IMAGE_BLOCK_COUNT}"

    sudo tar -zxvf ubuntu-base-20.04.1-base-arm64.tar.gz -C "${MNT_DIR}"
    sudo tar -zxvf yocoto.tar.gz -C "${MNT_DIR}"

    sudo apt-get install -y qemu-user-static
    sudo cp /usr/bin/qemu-aarch64-static "${MNT_DIR}/usr/bin"
    sudo cp -b /etc/resolv.conf "${MNT_DIR}/etc/"

    sudo cp install-package-for-stage-1.sh "${MNT_DIR}/root"
    sudo chmod u+x "${MNT_DIR}/root/install-package-for-stage-1.sh"

    sudo cp -r wayland-1.18.0 "${MNT_DIR}/root"
    sudo cp -r wayland-protocols-imx "${MNT_DIR}/root"
    sudo cp -r weston-imx "${MNT_DIR}/root"

    # copy ubuntu-ports mirror source
    sudo mv "${MNT_DIR}/etc/apt/sources.list" "${MNT_DIR}/etc/apt/sources.list.official"
    sudo cp -f ./sources.list.ustc "${MNT_DIR}/etc/apt/sources.list"

    # Chroot to rootfs & run setup scripts
    ./ch-mount.sh -m "${MNT_DIR}/" '/root/install-package-for-stage-1.sh'

    # Unmount rootfs
    ./ch-mount.sh -u "${MNT_DIR}/"

    # clean
    sudo apt-get clean
    sudo rm -rf "${MNT_DIR}/build"
    sudo rm -f "${MNT_DIR}/root/install-package-for-stage-1.sh"
    sudo rm -rf "${MNT_DIR}/root/wayland-1.18.0"
    sudo rm -rf "${MNT_DIR}/root/wayland-protocols-imx"
    sudo rm -rf "${MNT_DIR}/root/weston-imx"
    sudo rm -f "${MNT_DIR}/etc/apt/sources.list"
    sudo mv "${MNT_DIR}/etc/apt/sources.list.official" "${MNT_DIR}/etc/apt/sources.list"

    # unmount image
    umount_disk_image
}
