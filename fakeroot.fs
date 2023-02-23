set -e

rawsize=8192
fatsize=85184
ext4size=6815744

totalsize=`expr $rawsize + $fatsize + $ext4size + 1`

# Check if the environment variables are correct
if [ -z "$BUILD_DIR" ]; then
	echo "BUILD_DIR does not exist"
	exit 1
fi

if [ -z "$OUTPUT_DIR" ]; then
	echo "OUTPUT_DIR does not exist"
	exit 1
fi

if [ -z "$ROOTFS_DIR" ]; then
	echo "ROOTFS_DIR does not exist"
	exit 1
fi

EXT4_FILE=$BUILD_DIR/rootfs.ext4
SDCARD_FILE=$OUTPUT_DIR/rootfs.sdcard

if [ -e $EXT4_FILE ]; then
        rm -f $EXT4_FILE
fi

if [ -e $SDCARD_FILE ]; then
        rm -f $SDCARD_FILE
fi

echo "Making an empty ${EXT4_FILE}"
dd if=/dev/zero of=$EXT4_FILE bs=1K count=0 seek=$ext4size
echo "Total bytes = $totalbytes"
chown -h -R 0:0 $ROOTFS_DIR
find $ROOTFS_DIR -name .gitignore -delete
mkfs.ext4 -F -i 4096 $EXT4_FILE -d $ROOTFS_DIR
fsck.ext4 -pvfD $EXT4_FILE

#find $ROOTFS_DIR -type d -empty -exec touch {}/.gitignore \;

fatstart=$rawsize
fatend=`expr $rawsize + $fatsize`
ext4start=`expr $fatend`
ext4end=`expr $fatend + $ext4size`
echo $ext4end

dd if=/dev/zero of=$SDCARD_FILE bs=1K count=0 seek=$totalsize
parted -s $SDCARD_FILE mklabel msdos
parted -s $SDCARD_FILE unit KiB mkpart primary fat32 $fatstart $fatend
parted -s $SDCARD_FILE unit KiB mkpart primary $ext4start $ext4end
parted $SDCARD_FILE unit B print

echo $fatstartbytes
echo $ext4startbytes
dd if=./boot.img of=$SDCARD_FILE conv=notrunc,fsync seek=1K bs=$fatstart
dd if=$EXT4_FILE of=$SDCARD_FILE conv=notrunc,fsync seek=1K bs=$ext4start
rm -rf $EXT4_FILE

echo "Finish making sdcard image! You should see it in the output directory."
