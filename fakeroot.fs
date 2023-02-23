set -e

rawsize=8192
fatsize=85184
ext4size=6815744

totalsize=`expr $rawsize + $fatsize + $ext4size + 1`

EXT4_FILE=$BUILD_DIR/rootfs.ext4
SDCARD_FILE=$OUTPUT_DIR/rootfs.sdcard

if [ -e $EXT4_FILE ]; then
        rm -f $EXT4_FILE
fi

if [ -e $SDCARD_FILE ]; then
        rm -f $SDCARD_FILE
fi

dd if=/dev/zero of=$EXT4_FILE bs=1K count=0 seek=$ext4size
echo $totalbytes
chown -h -R 0:0 $DESTDIR
find $DESTDIR -name .gitignore -exec rm {} \;
#$SDK_PATH/tools/bin/mkfs.ext4 -F -i 4096 $EXT4_FILE -d $DESTDIR
#$SDK_PATH/tools/bin/fsck.ext4 -pvfD $EXT4_FILE
mkfs.ext4 -F -i 4096 $EXT4_FILE -d $DESTDIR
fsck.ext4 -pvfD $EXT4_FILE

#find $DESTDIR -type d -empty -exec touch {}/.gitignore \;

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

#dd if=$SDK_PATH/images/flash_sd_emmc.bin of=$SDCARD_FILE conv=notrunc seek=33 bs=1K
echo $fatstartbytes
echo $ext4startbytes
dd if=$SDK_PATH/images/boot.img of=$SDCARD_FILE conv=notrunc,fsync seek=1K bs=$fatstart
dd if=$EXT4_FILE of=$SDCARD_FILE conv=notrunc,fsync seek=1K bs=$ext4start
#split -b 2G $SDCARD_FILE $SDCARD_FILE.
rm -rf $EXT4_FILE
#rm -rf $SDCARD_FILE

