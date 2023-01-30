# NXP & OpenPilot Rootfs构建仓库

# 仓库文件描述  
build.sh: 库解压和rootfs基础文件生成    
install_package.sh: rootfs内执行的库安装和编译脚本  
ch-mount.sh: chroot脚本  
yocoto.tar.gz: 根据开发板预编译的库文件  
ubuntu-base-20.04.1-base-arm64.tar.gz: 在ubuntu官网下载的20.04 arm64基础rootfs  
wayland*: wayland源码  
weston-imx: weston源码  

# 编译过程

## 基础rootfs
执行./build.sh构建基础rootfs并chroot到该目录，目录显示应该如下图：
![image](https://user-images.githubusercontent.com/22252972/215438497-3391e466-e3e9-42e4-ad58-ffaf9a34f2e7.png)

## rootfs内部构建
chroot后进入到/root目录，执行install_package.sh即可编译并安装所需脚本

### 执行后截图
![image](https://user-images.githubusercontent.com/22252972/215435026-7952fe93-a0d8-4596-b78d-ce330ac00bbd.png)



