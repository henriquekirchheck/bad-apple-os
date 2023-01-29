export KERNEL_MAJOR_VERSION := 6
export KERNEL_MINOR_VERSION := 1
export KERNEL_PATCH_VERSION := 7
export BUILDROOT_VERSION := 2022.11.1
export MUSL_LIBC_VERSION := 1.2.3
export BUSYBOX_VERSION := 1.36.0
export LIBGCC_VERSION := 12.2.0_1
export LIBVPX_VERSION := 1.12.0
export LIBOPUS_VERSION := 1.3.1
export SHADERC_VERSION := 2022.4
export BROTLI_VERSION := 1.0.9
export PCRE2_VERSION := 10.42
export ZLIB_VERSION := 1.2.13
export BZIP2_VERSION := 1.0.8
export SPIRV_TOOLS_VERSION := 2022.4
export SPIRV_HEADERS_VERSION := 1.3.236.0
export GLSLANG_VERSION := 11.13.0
export ALSA_LIB_VERSION := 1.2.8
export ALSA_TOPOLOGY_CONF_VERSION := 1.2.5.1
export ALSA_UCM_CONF_VERSION := 1.2.8
export ROOTFS := ${CURDIR}/build/rootfs
export JOBS := $(shell echo $$(( $$(nproc) - 1 )))

all: fetch build
fetch: fetch_kernel fetch_buildroot fetch_musl_libc fetch_busybox fetch_alsa fetch_libgcc fetch_libvpx fetch_opus fetch_spirv_tools fetch_glslang fetch_shaderc fetch_brotli fetch_zlib fetch_bzip2 fetch_pcre2
build: build_rootfs build_linux build_buildroot_toolchain build_musl_libc build_busybox build_alsa build_libgcc build_libvpx build_opus build_spirv_tools build_glslang build_shaderc build_brotli build_zlib build_bzip2 build_pcre2

fetch_%:
	./utils/fetch.sh $@

build_%:
	./utils/build.sh $@

iso:
	./utils/iso.sh

.PHONY: all fetch fetch_% build build_% iso