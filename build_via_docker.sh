#!/bin/bash -e

# Author: Charlie
# Note: 
#   The build process, except minor deviations for adapting to our target device, i.e., the OK8MP devboard,
#   essentially follows the following document:
#	build.sh 	
#   which is already an adaptation to
#	Enable Ubuntu on i.MX8MP.pdf
#   The benefit of using docker is that you do not have to redo the entire process in case something goes wrong.

#   For the first step: Build Yocto L5.4.3_2.0.0_GA, please follow the official document by NXP:
#	i.MX Yocto Project User's Guide
#   from Section 3 through to Section 5.2. You will need a huge disk (>1TB) and good network connection for
#   a successful build. In this repository we provide you with the readily built libraries packaged in
#	yocoto.tar.gz

# Make sure we're in the correct spot
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd $DIR

# Check we have the required packages and libraries. Download Ubuntu Base if not done already
UBUNTU_BASE_URL="http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release"
UBUNTU_FILE="ubuntu-base-20.04.1-base-arm64.tar.gz"
YOCTO_FILE="yocoto.tar.gz"
if [ ! -f $UBUNTU_FILE ]; then
  echo -e "${GREEN}Downloading Ubuntu: $UBUNTU_FILE ${NO_COLOR}"
  wget -c $UBUNTU_BASE_URL/$UBUNTU_FILE --quiet
fi
if [ ! -f $YOCTO_FILE ]; then
  echo -e "${RED}Require built libraries compressed within $YOCTO_FILE . Please follow i.MX Yocto Project Users Guide. ${NO_COLOR}"
  exit 1
fi

# Install qemu
# sudo apt-get install -y qemu-user-static  

# Start docker build
echo "Building image"
export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL=enabled
docker build -f Dockerfile -t ok8mp-ubuntu-builder $DIR

if [ "$1" == "buildfs" ]; then

BUILD_DIR="$DIR/build"
OUTPUT_DIR="$DIR/output"

ROOTFS_DIR="$BUILD_DIR/ok8mp-rootfs"
ROOTFS_IMAGE="$BUILD_DIR/system.img.raw"
ROOTFS_IMAGE_SIZE=10G
SPARSE_IMAGE="$BUILD_DIR/system.img"

# Create temp dir if non-existent
mkdir -p $BUILD_DIR $OUTPUT_DIR

# Create filesystem ext4 image
echo "Creating empty filesystem"
fallocate -l $ROOTFS_IMAGE_SIZE $ROOTFS_IMAGE
mkfs.ext4 $ROOTFS_IMAGE > /dev/null

# Mount filesystem
echo "Mounting empty filesystem"
mkdir -p $ROOTFS_DIR
sudo umount -l $ROOTFS_DIR > /dev/null || true
sudo mount $ROOTFS_IMAGE $ROOTFS_DIR

# Extract image
echo "Extracting docker image"
CONTAINER_ID=$(docker container create --entrypoint /bin/bash ok8mp-ubuntu-builder:latest)
docker container export -o $BUILD_DIR/filesystem.tar $CONTAINER_ID
docker container rm $CONTAINER_ID > /dev/null
echo "Extract to build/filesystem.tar ..."
cd $ROOTFS_DIR
sudo tar -xf $BUILD_DIR/filesystem.tar > /dev/null

# Add hostname and hosts. This cannot be done in the docker container...
echo "Setting network stuff"
HOST=tici
sudo bash -c "echo $HOST > etc/hostname"
sudo bash -c "echo \"127.0.0.1    localhost.localdomain localhost\" > etc/hosts"
sudo bash -c "echo \"127.0.0.1    $HOST\" >> etc/hosts"

# Fix resolv config
sudo bash -c "ln -sf /run/systemd/resolve/stub-resolv.conf etc/resolv.conf"

# Write build info
DATETIME=$(date '+%Y-%m-%dT%H:%M:%S')
GIT_HASH=$(git --git-dir=$DIR/.git rev-parse HEAD)
sudo bash -c "printf \"$GIT_HASH\n$DATETIME\" > BUILD"

cd $DIR

# Unmount image
echo "Unmount filesystem"
sudo umount -l $ROOTFS_DIR

echo "Done!"

fi
