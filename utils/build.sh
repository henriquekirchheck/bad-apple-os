PATH="${PWD}/build/compile/crosscompile/buildroot-${BUILDROOT_VERSION}/output/host/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
CROSSCC="x86_64-buildroot-linux-musl"

build_rootfs() {
  mkdir -p build/rootfs/{etc,usr,dev,proc,sys,usr/{bin,lib,sbin,include},tmp,run}
  pushd build/rootfs || exit 1
    ln -s usr/bin bin
    ln -s usr/lib lib
    ln -s usr/sbin sbin
  popd || exit 1
  cp bin/init build/rootfs
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
    make -j"${JOBS}" CROSS_COMPILE="${CROSSCC}-" ARCH="x86_64" CONFIG_STATIC=y busybox
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

build_spirv_tools() {
  pushd build/compile/lib/"SPIRV-Headers-sdk-${SPIRV_HEADERS_VERSION}" || exit 1
    cmake \
      -Bbuild \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
      -DCMAKE_SYSROOT="${ROOTFS}" \
      -DCMAKE_C_COMPILER="${CROSSCC}-gcc" \
      -DCMAKE_CXX_COMPILER="${CROSSCC}-g++"

    make -j"${JOBS}" -c build
    make -C build DESTDIR="${ROOTFS}" install
  popd || exit 1

  pushd build/compile/lib/"SPIRV-Tools" || exit 1
    cmake \
      -Bbuild \
      -GNinja \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=None \
      -DSPIRV_WERROR=Off \
      -DBUILD_SHARED_LIBS=ON \
      -DSPIRV_TOOLS_BUILD_STATIC=OFF \
      -DSPIRV-Headers_SOURCE_DIR=/usr \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
      -DCMAKE_SYSROOT="${ROOTFS}" \
      -DCMAKE_C_COMPILER="${CROSSCC}-gcc" \
      -DCMAKE_CXX_COMPILER="${CROSSCC}-g++"

    ninja -C build

    DESTDIR="${ROOTFS}" ninja -C build install
  popd || exit 1
}

build_glslang() {
  pushd build/compile/lib/"glslang-${GLSLANG_VERSION}" || exit 1
    CXXFLAGS+=" -ffat-lto-objects"
    cmake \
      -Bbuild-shared \
      -GNinja \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=None \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
      -DCMAKE_SYSROOT="${ROOTFS}" \
      -DCMAKE_CXX_COMPILER="${CROSSCC}-g++"
    ninja -Cbuild-shared

    cmake \
      -Bbuild-static \
      -GNinja \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=None \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
      -DCMAKE_SYSROOT="${ROOTFS}" \
      -DCMAKE_CXX_COMPILER="${CROSSCC}-g++"
    ninja -Cbuild-static

    DESTDIR="${ROOTFS}" ninja -C build-shared install
    DESTDIR="${ROOTFS}" ninja -C build-static install
  popd || exit 1
}

build_shaderc() {
  pushd build/compile/lib/"shaderc-${SHADERC_VERSION}" || exit 1
    sed '/examples/d;/third_party/d' -i CMakeLists.txt
    sed '/build-version/d' -i glslc/CMakeLists.txt

cat <<- EOF > glslc/src/build-version.inc
"${GLSLANG_VERSION}\\n"
"${SPIRV_TOOLS_VERSION}\\n"
"${GLSLANG_VERSION}\\n"
EOF

    cmake \
      -Bbuild \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS} -ffat-lto-objects" \
      -DSHADERC_SKIP_TESTS=ON \
      -Dglslang_SOURCE_DIR="${ROOTFS}/usr/include/glslang" \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
      -DCMAKE_SYSROOT="${ROOTFS}" \
      -DCMAKE_C_COMPILER="${CROSSCC}-gcc" \
      -DCMAKE_CXX_COMPILER="${CROSSCC}-g++"
    ninja -C build

    DESTDIR="${ROOTFS}" ninja -C build install
  popd || exit 1
}

build_brotli() {
  pushd build/compile/lib/"brotli-${BROTLI_VERSION}" || exit 1
    cmake \
      -Bbuild \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_SHARED_LIBS=True \
      -DCMAKE_C_FLAGS="${CFLAGS} -ffat-lto-objects" \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
      -DCMAKE_SYSROOT="${ROOTFS}" \
      -DCMAKE_C_COMPILER="${CROSSCC}-gcc" \
      -DCMAKE_CXX_COMPILER="${CROSSCC}-g++"

    cmake --build build -v
    DESTDIR="${ROOTFS}" cmake --install build
  popd || exit 1
}

build_zlib() {
  pushd build/compile/lib/"zlib-${ZLIB_VERSION}" || exit 1
    CFLAGS+=" -ffat-lto-objects"
    CROSS_PREFIX="${CROSSCC}-" ./configure \
      --prefix=/usr

    make -j"$PROCS"

    make DESTDIR="${ROOTFS}" install

  popd || exit 1
}

build_bzip2() {
  pushd build/compile/lib/"bzip2-bzip2-${BZIP2_VERSION}" || exit 1
    make -f Makefile-libbz2_so CC="${CROSSCC}-gcc -L${ROOTFS}/usr/lib"
    make bzip2 bzip2recover CC="${CROSSCC}-gcc" AR="${CROSSCC}-ar" LDFLAGS="-L${ROOTFS}/usr/lib"

    cp -a bzip2-shared "${ROOTFS}"/usr/bin/bzip2
    cp -a bzip2recover bzdiff bzgrep bzmore "${ROOTFS}"/usr/bin
    ln -sf bzip2 "${ROOTFS}"/usr/bin/bunzip2
    ln -sf bzip2 "${ROOTFS}"/usr/bin/bzcat

    cp -a libbz2.a "${ROOTFS}"/usr/lib
    cp -a libbz2.so* "${ROOTFS}"/usr/lib
    ln -s libbz2.so."${BZIP2_VERSION}" "${ROOTFS}"/usr/lib/libbz2.so
    ln -s libbz2.so."${BZIP2_VERSION}" "${ROOTFS}"/usr/lib/libbz2.so.1

    cp -a bzlib.h "${ROOTFS}"/usr/include
  popd || exit 1
}

build_pcre2() {
  pushd build/compile/lib/"pcre2-${PCRE2_VERSION}" || exit 1
    CFLAGS+=" -ffat-lto-objects"
    CXXFLAGS+=" -ffat-lto-objects"

    CPPFLAGS="-I${ROOTFS}/usr/include" \
    CC="${CROSSCC}-gcc" \
    LDFLAGS="-L${ROOTFS}/usr/lib" \
    PKG_CONFIG_LIBDIR="${ROOTFS}/usr/lib" \
    ./configure \
      --prefix=/usr \
      --enable-pcre2-16 \
      --enable-pcre2-32 \
      --enable-jit \
      --enable-pcre2grep-libz \
      --enable-pcre2grep-libbz2 \
      --host=x86_64-pc-linux-musl

    make -j"$PROCS"
    make DESTDIR="${ROOTFS}" install
  popd || exit 1
}

$1;