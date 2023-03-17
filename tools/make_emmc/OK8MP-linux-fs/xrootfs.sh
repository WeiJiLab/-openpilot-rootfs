#!/bin/bash -e

if [ -e rootfs ]; then
	rm -rf rootfs
fi

mkdir rootfs
mv filesystem.tar rootfs
cd rootfs
tar xf filesystem.tar
mv filesystem.tar ../

