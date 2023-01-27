mkdir -p build/iso/boot/grub
pushd build/rootfs || exit 1
  find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > ../iso/boot/initramfs.cpio.gz
popd || exit 1
cp build/compile/kernel/bzImage build/iso/boot
cp config/grub.cfg build/iso/boot/grub
mkdir -p output
grub-mkrescue -o output/bad-apple-os-x86_64.iso build/iso/