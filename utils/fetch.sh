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

fetch_libvpx() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://chromium.googlesource.com/webm/libvpx/+archive/v${LIBVPX_VERSION}.tar.gz" -O "libvpx-${LIBVPX_VERSION}.tar.gz"
    tar --one-top-level="libvpx-${LIBVPX_VERSION}" -xv --keep-newer-files -f "libvpx-${LIBVPX_VERSION}.tar.gz"
  popd || exit 1
}

fetch_opus() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://archive.mozilla.org/pub/opus/opus-${LIBOPUS_VERSION}.tar.gz"
    tar -xv --keep-newer-files -f "opus-${LIBOPUS_VERSION}.tar.gz"
  popd || exit 1
}

fetch_spirv_tools() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/sdk-${SPIRV_HEADERS_VERSION}/spirv-headers-${SPIRV_HEADERS_VERSION}.tar.gz"
    git clone --depth 1 --branch "v${SPIRV_TOOLS_VERSION}" "https://github.com/KhronosGroup/SPIRV-Tools.git"
    tar -xv --keep-newer-files -f "spirv-headers-${SPIRV_HEADERS_VERSION}.tar.gz"
  popd || exit 1
}

fetch_glslang() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://github.com/KhronosGroup/glslang/archive/${GLSLANG_VERSION}.tar.gz" -O "glslang-${GLSLANG_VERSION}.tar.gz"
    tar --one-top-level="glslang-${GLSLANG_VERSION}" -xv --keep-newer-files -f "glslang-${GLSLANG_VERSION}.tar.gz"
  popd || exit 1
}

fetch_shaderc() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://github.com/google/shaderc/archive/v${SHADERC_VERSION}/shaderc-${SHADERC_VERSION}.tar.gz"
    tar -xv --keep-newer-files -f "shaderc-${SHADERC_VERSION}.tar.gz"
  popd || exit 1
}

fetch_brotli() {
  mkdir -p build/compile/lib
  pushd build/compile/lib || exit 1
    wget -N "https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz" -O "brotli-${BROTLI_VERSION}.tar.gz"
    tar --one-top-level="brotli-${BROTLI_VERSION}" -xv --keep-newer-files -f "brotli-${BROTLI_VERSION}.tar.gz"
  popd || exit 1
}

$1