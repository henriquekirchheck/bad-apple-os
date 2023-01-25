export KERNEL_MAJOR_VERSION := 6
export KERNEL_MINOR_VERSION := 1
export KERNEL_PATCH_VERSION := 7
export BUILDROOT_VERSION := 2022.11.1
export MUSL_LIBC_VERSION := 1.2.3
export BUSYBOX_VERSION := 1.36.0
export ROOTFS := ${CURDIR}/build/rootfs
export JOBS := $(shell echo $$(( $$(nproc) - 1 )))

all: fetch build
fetch: fetch_kernel fetch_buildroot fetch_musl_libc fetch_busybox
build: build_rootfs build_linux build_buildroot_toolchain build_musl_libc build_busybox

fetch_%:
	./utils/fetch.sh $@

build_%:
	./utils/build.sh $@

.PHONY: all fetch fetch_% build build_%