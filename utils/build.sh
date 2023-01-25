PATH="${PWD}/build/compile/crosscompile/buildroot-${BUILDROOT_VERSION}/output/host/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
CROSSCC="x86_64-buildroot-linux-musl"

build_rootfs() {
  mkdir -p build/rootfs/{etc,usr,dev,proc,sys,usr/{bin,lib,sbin,include},tmp}
  pushd build/rootfs || exit 1
    ln -s usr/bin bin
    ln -s usr/lib lib
    ln -s usr/sbin sbin
  popd || exit 1
}

build_linux() {
  pushd build/compile/kernel/"linux-${KERNEL_MAJOR_VERSION}.${KERNEL_MINOR_VERSION}.${KERNEL_PATCH_VERSION}" || exit 1
    cp ../../../../config/linux.x86_64.config ./.config
    make -j"${JOBS}"
    cp arch/x86_64/boot/bzImage ../
  popd || exit 1
}

build_buildroot_toolchain() {
  pushd build/compile/crosscompile/"buildroot-${BUILDROOT_VERSION}" || exit 1
    cp ../../../../config/buildroot.x86_64.config ./.config
    make toolchain -j"${JOBS}"
  popd || exit 1
}

build_musl_libc() {
  pushd build/compile/lib/"musl-${MUSL_LIBC_VERSION}" || exit 1
    CROSS_COMPILE="${CROSSCC}-" CC="${CROSSCC}-gcc" ./configure --prefix=/usr --target=x86_64
    make -j"${JOBS}"
    make install DESTDIR="${ROOTFS}"
  popd || exit 1
}

build_busybox() {
  pushd build/compile/bin/"busybox-${BUSYBOX_VERSION}" || exit 1
    cp ../../../../config/busybox-x86_64.config ./.config
    make -j"${JOBS}" CROSS_COMPILE="${CROSSCC}-" ARCH="x86_64"
    make install CONFIG_PREFIX="${ROOTFS}"
  popd || exit 1
}

$1;