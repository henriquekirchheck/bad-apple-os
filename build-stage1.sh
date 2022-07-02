#!/bin/bash

source "$(pwd)/env.sh"

build_musl () {
  pushd $BUILD_FOLDER/musl-$MUSLLIBC_VERSION > /dev/null
    CC="gcc" CFLAGS="-static" ./configure --prefix=$ROOTFS_FOLDER
    make
    make install
  popd > /dev/null
}

build_linux () {
  pushd $BUILD_FOLDER/linux-$LINUX_VERSION > /dev/null
    cp $SRC_FOLDER/linux.config .config
    make all
    make install INSTALL_MOD_PATH="$ROOTFS_FOLDER" INSTALL_PATH="$ROOTFS_FOLDER/boot"
    make modules_install INSTALL_MOD_PATH="$ROOTFS_FOLDER" INSTALL_PATH="$ROOTFS_FOLDER/boot"
  popd > /dev/null
}

build_musl
build_linux
