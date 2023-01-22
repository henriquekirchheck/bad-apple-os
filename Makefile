export BUILDROOT_VERSION := 2022.11.1
export KERNEL_MAJOR_VERSION := 6
export KERNEL_MINOR_VERSION := 1
export KERNEL_PATCH_VERSION := 7

.PHONY: fetch
fetch:
	./utils/fetch.sh