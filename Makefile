export BUILDROOT_VERSION := 2022.11.1
export KERNEL_MAJOR_VERSION := 6
export KERNEL_MINOR_VERSION := 1
export KERNEL_PATCH_VERSION := 7
export JOBS := $(shell echo $$(( $$(nproc) - 1 )))

.PHONY: all
all: fetch build

.PHONY: fetch
fetch:
	./utils/fetch.sh

.PHONY: build
build: build_rootfs build_linux build_buildroot_toolchain

.PHONY: build_%
build_%:
	./utils/build.sh $@
