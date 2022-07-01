#!/bin/bash

source "$(pwd)/env.sh"

clean-warn () {
  echo "Please run clean script"
  exit 1
}

download_files () {
  rsync --info=PROGRESS "rsync://rsync.kernel.org/pub/linux/kernel/v5.x/linux-${LINUX_VERSION}.tar.xz" $BUILD_FOLDER
  wget -P "$BUILD_FOLDER" "https://musl.libc.org/releases/musl-${MUSLLIBC_VERSION}.tar.gz"
  wget -P "$BUILD_FOLDER" "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
}

extract_files () {
  for file in $BUILD_FOLDER/*.tar.*; do
    tar -xvf $file -C $BUILD_FOLDER
  done
}

[ -d $ROOTFS_FOLDER ] && clean-warn || mkdir $ROOTFS_FOLDER
[ -d $BUILD_FOLDER ]  && clean-warn || mkdir $BUILD_FOLDER

mkdir $ROOTFS_FOLDER/{dev,sys,proc,usr,tmp,etc} -p
mkdir $ROOTFS_FOLDER/usr/{bin,share,local,lib} -p

pushd $ROOTFS_FOLDER > /dev/null
  ln -s usr/bin bin
  ln -s usr/bin sbin
  ln -s usr/lib lib
  ln -s usr/lib lib64
popd > /dev/null
pushd $ROOTFS_FOLDER/usr > /dev/null
  ln -s bin sbin
  ln -s lib lib64
popd > /dev/null

# download_files
extract_files