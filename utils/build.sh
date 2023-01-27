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
    cp ../../../../config/busybox.x86_64.config ./.config
    make -j"${JOBS}" CROSS_COMPILE="${CROSSCC}-" ARCH="x86_64"
    make install CONFIG_PREFIX="${ROOTFS}"
  popd || exit 1
}

build_alsa() {
  mkdir -p "${ROOTFS}/usr/share/alsa"

  pushd build/compile/lib/"alsa-topology-conf-${ALSA_TOPOLOGY_CONF_VERSION}" || exit 1
    mkdir -p "${ROOTFS}/usr/share/alsa/topology"
    for dir in topology/*; do
      mkdir -p "${ROOTFS}/usr/share/alsa/topology/$(basename "$dir")"
      cp -a "${dir}"/*.conf "${ROOTFS}/usr/share/alsa/topology/$(basename "$dir")"
    done
  popd || exit 1

  pushd build/compile/lib/"alsa-ucm-conf-${ALSA_UCM_CONF_VERSION}" || exit 1
    cp -a ucm2 "${ROOTFS}/usr/share/alsa/"
  popd || exit 1

  pushd build/compile/lib/"alsa-lib-${ALSA_LIB_VERSION}" || exit 1
    CFLAGS+=" -flto-partition=none"

    CC="${CROSSCC}-gcc" LDFLAGS="-L${ROOTFS}/usr/lib" ./configure --host=x86_64-pc-linux-musl --prefix=/usr --without-debug

    sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
    make -j"${JOBS}"

    make DESTDIR="${ROOTFS}" install
  popd || exit 1
}

build_libgcc() {
  pushd build/compile/lib/"libgcc-${LIBGCC_VERSION}" || exit 1
    cp -r ./* "${ROOTFS}/"
  popd || exit 1
}

build_libvpx() {
  pushd build/compile/lib/"libvpx-${LIBVPX_VERSION}" || exit 1
    CFLAGS+=" -ffat-lto-objects"
    CXXFLAGS+=" -ffat-lto-objects"

    LDFLAGS="-L${ROOTFS}/usr/lib" CROSS="${CROSSCC}-" ./configure \
      --target=generic-gnu \
      --prefix=/usr \
      --disable-install-docs \
      --disable-install-srcs \
      --disable-unit-tests \
      --enable-pic \
      --enable-postproc \
      --enable-runtime-cpu-detect \
      --enable-shared \
      --enable-vp8 \
      --enable-vp9 \
      --enable-vp9-highbitdepth \
      --enable-vp9-temporal-denoising

    make -j"${JOBS}"
    make DIST_DIR="${ROOTFS}/usr" install
  popd || exit 1
}

build_opus() {
  pushd build/compile/lib/"opus-${LIBOPUS_VERSION}" || exit 1
    LDFLAGS="-L${ROOTFS}/usr/lib" CC="${CROSSCC}-gcc" ./configure --prefix=/usr --disable-static --enable-custom-modes --host=x86_64-linux-musl --with-sysroot="${ROOTFS}"

    make -j"${JOBS}"
    make DESTDIR="${ROOTFS}" install
  popd || exit 1
}

$1;