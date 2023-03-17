#!/bin/bash
#
function mnt() {
	echo "MOUNTING"
	sudo mount -t proc /proc ${2}proc
	sudo mount -t sysfs /sys ${2}sys
	sudo mount -o bind /dev ${2}dev
	sudo mount -o bind /dev/pts ${2}dev/pts
    sudo mount -o bind /tmp ${2}tmp

    if [ -n "${3}" ]; then
	   sudo chroot "${2}" /bin/bash -c "${3}"
    else
       sudo chroot "${2}"
    fi
}
function umnt() {
	echo "UNMOUNTING" 
	sudo umount ${2}proc
	sudo umount ${2}sys
	sudo umount ${2}dev/pts
	sudo umount ${2}dev
    sudo umount ${2}tmp
}
if [ "$1" == "-m" ] && [ -n "$2" ]; then
    if [ -n "$3" ]; then
	    mnt "$1" "$2" "$3"
    else
        mnt "$1" "$2"
    fi
elif [ "$1" == "-u" ] && [ -n "$2" ]; then
	umnt "$1" "$2"
else
	echo ""
	echo "Either 1'st, 2'nd or both parameters were missing"
	echo ""
	echo "1'st parameter can be one of these: -m(mount) OR -u(umount)" echo "2'nd parameter is the full path of rootfs directory(with trailing '/')"
	echo ""
	echo "For example: ch-mount -m /media/sdcard/"
	echo ""
	echo 1st parameter : ${1}
	echo 2nd parameter : ${2}
fi
