export KERNEL_MAJOR_VERSION := 6
export KERNEL_MINOR_VERSION := 1
export KERNEL_PATCH_VERSION := 7
export BUILDROOT_VERSION := 2022.11.1
export MUSL_LIBC_VERSION := 1.2.3
export ROOTFS := ${CURDIR}/build/rootfs
export JOBS := $(shell echo $$(( $$(nproc) - 1 )))

.PHONY: all
all: fetch build

.PHONY: fetch
fetch: fetch_kernel fetch_buildroot fetch_musl_libc

.PHONY: fetch_%
fetch_%:
	./utils/fetch.sh $@

.PHONY: build
build: build_rootfs build_linux build_buildroot_toolchain

.PHONY: build_%
build_%:
	./utils/build.sh $@
