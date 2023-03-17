#!/bin/bash -e

# if we have the latest sdcard image
if [ -e ok8mp-linux-fs.sdcard ]; then
	if [ -e rootfs.sdcard ]; then
		rm -f rootfs.sdcard
	fi
	mv ok8mp-linux-fs.sdcard rootfs.sdcard
fi
sudo uuu -b emmc_all imx-boot.bin rootfs.sdcard
