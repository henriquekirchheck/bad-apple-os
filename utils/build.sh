build_rootfs() {
  mkdir -p build/rootfs/{etc,usr,dev,proc,sys,usr/{bin,lib,sbin}}
  pushd build/rootfs || exit 1
    ln -s usr/bin bin
    ln -s usr/lib lib
    ln -s usr/sbin sbin
  popd || exit 1
}

build_linux() {
  pushd build/compile/kernel/"linux-${KERNEL_MAJOR_VERSION}.${KERNEL_MINOR_VERSION}.${KERNEL_PATCH_VERSION}" || exit 1
    cp ../../../../config/linux.x86_64.config ./.config
    make -j${JOBS}
    cp arch/x86_64/boot/bzImage ../
  popd || exit 1
}

$1;