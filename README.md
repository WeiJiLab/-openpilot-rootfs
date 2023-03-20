


# NXP & OpenPilot Rootfs

## 仓库描述

* yocoto.tar.gz: 根据开发板预编译的库文件
* ubuntu-base-20.04.1-base-arm64.tar.gz: 在ubuntu官网下载的20.04 arm64基础rootfs
* wayland*: wayland源码
* weston-imx: weston源码



## 构建

### 使用build.sh构建

下面是build.sh的usages信息

```shell
$ ./build.sh -h
Usages:
  -s | --stage  indicates run which stage of build. valid value are "1, 2, 3, all"
  -i | --image  target image path
  -b | --block-count  block count of target image. 1M per block
  -h | --help   show usages
Example:
  for build all stages
    ./build.sh -s all './images/rootfs.img' -b 6000
  if you only want to build one stage, you can choose following command with you status
    stage 1:
      ./build.sh -s 1 -i './images/rootfs.img' -b 6000
    stage 2:
      ./build.sh -s 2 -i './images/rootfs.img'
    stage 3:
      ./build.sh -s 3 -i './images/rootfs.img'
```

使用build.sh构建时，该构建过程被分为3个stage

* stage 1: 在base image（Ubuntu 20.04 arm64）的基础上，添加基本依赖库。如：qemu、wayland、waston等，并创建用户“lito”；

* stage 2: 为OpenPilot的构建添加依赖支持。安装依赖包，并创建pyenv环境；

* stage 3: 构建OpenPilot。

使用者可以根据需要进行全量构建，或者指定stage构建。

在使用“-s all”或“-s 1”时，需指定创建的image的存储位置及block count，这里，一个block大小为1M。因此“-b 6000”意味着创建一个6GB大小的image。image将自动创建，并且文件系统格式为ext4。

对于Stage 2 和 3，不需指定block count，但需要保证指定的image存在，并且已完成上一个Stage的构建，否则构建会失败。



### 使用Docker构建

见 [How to build and extract a rootfs via Docker](https://github.com/WeiJiLab/openpilot-rootfs/wiki/How-to-build-a-rootfs-via-Docker)
