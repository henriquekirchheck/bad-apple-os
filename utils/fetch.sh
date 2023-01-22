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

fetch() {
  fetch_kernel
  fetch_buildroot
}

fetch