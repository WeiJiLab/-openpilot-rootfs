#!/bin/bash -e

# Author: Charlie
# Note: 
#   The build process, except minor deviations for adapting to our target device, i.e., the OK8MP devboard,
#   essentially follows the following document:
# 	Enable Ubuntu on i.MX8MP.pdf
#   For the first step: Build Yocto L5.4.3_2.0.0_GA, please follow the official document by NXP:
#	i.MX Yocto Project User's Guide
#   from Section 3 through to Section 5.2. You will need a huge disk (>1TB) and good network connection for
#   a successful build. In this repository we provide you with the readily built libraries contained in
#	yocoto.tar.gz

# Check we have the required packages and libraries. Download Ubuntu Base if not done already
UBUNTU_BASE_URL="http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release"
UBUNTU_FILE="ubuntu-base-20.04.1-base-arm64.tar.gz"
YOCTO_FILE="yocoto.tar.gz"
if [ ! -f $UBUNTU_FILE ]; then
  echo -e "${GREEN}Downloading Ubuntu: $UBUNTU_FILE ${NO_COLOR}"
  wget -c $UBUNTU_BASE_URL/$UBUNTU_FILE --quiet
fi
if [! -f $YOCTO_FILE ]; then
  echo -e "${RED}Require built libraries compressed within $YOCTO_FILE . Please follow i.MX Yocto Project Users Guide. ${NO_COLOR}"
  exit 1
fi


