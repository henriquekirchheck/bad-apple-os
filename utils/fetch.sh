fetch_kernel() {
  mkdir -p build/compile/kernel
  pushd build/compile/kernel || exit 1
    wget -N "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR_VERSION}.x/linux-${KERNEL_MAJOR_VERSION}.${KERNEL_MINOR_VERSION}.${KERNEL_PATCH_VERSION}.tar.xz"
    tar -xv --keep-newer-files -f "linux-${KERNEL_MAJOR_VERSION}.${KERNEL_MINOR_VERSION}.${KERNEL_PATCH_VERSION}.tar.xz"
  popd || exit 1
}

fetch_buildroot() {
  mkdir -p build/compile/crosscompile
  pushd build/compile/crosscompile || exit 1
    wget -N "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.xz"
    tar -xv --keep-newer-files -f  "buildroot-${BUILDROOT_VERSION}.tar.xz"
  popd || exit 1
}

fetch_musl_libc() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://musl.libc.org/releases/musl-${MUSL_LIBC_VERSION}.tar.gz"
    tar -xv --keep-newer-files -f "musl-${MUSL_LIBC_VERSION}.tar.gz"
  popd || exit 1
}

fetch_busybox() {
  mkdir -p build/compile/bin
  pushd build/compile/bin || exit 1
    wget -N "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
    tar -xv --keep-newer-files -f "busybox-${BUSYBOX_VERSION}.tar.bz2"
  popd || exit 1
}

fetch_alsa() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://www.alsa-project.org/files/pub/lib/alsa-lib-${ALSA_LIB_VERSION}.tar.bz2"
    wget -N "https://www.alsa-project.org/files/pub/lib/alsa-topology-conf-${ALSA_TOPOLOGY_CONF_VERSION}.tar.bz2"
    wget -N "https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-${ALSA_UCM_CONF_VERSION}.tar.bz2"
    tar -xv --keep-newer-files -f "alsa-lib-${ALSA_LIB_VERSION}.tar.bz2"
    tar -xv --keep-newer-files -f "alsa-topology-conf-${ALSA_TOPOLOGY_CONF_VERSION}.tar.bz2"
    tar -xv --keep-newer-files -f "alsa-ucm-conf-${ALSA_UCM_CONF_VERSION}.tar.bz2"
  popd || exit 1
}

fetch_libgcc() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://alpha.de.repo.voidlinux.org/current/musl/libgcc-${LIBGCC_VERSION}.x86_64-musl.xbps"
    wget -N "https://alpha.de.repo.voidlinux.org/current/musl/libstdc++-${LIBGCC_VERSION}.x86_64-musl.xbps"
    tar --one-top-level="libgcc-${LIBGCC_VERSION}" -xv --keep-newer-files -f "libgcc-${LIBGCC_VERSION}.x86_64-musl.xbps"
    tar --one-top-level="libgcc-${LIBGCC_VERSION}" -xv --keep-newer-files -f "libstdc++-${LIBGCC_VERSION}.x86_64-musl.xbps"
    rm "libgcc-${LIBGCC_VERSION}"/*.plist
  popd || exit 1
}

$1