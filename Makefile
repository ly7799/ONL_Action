SHELL=/bin/bash

dest_dir ?= $(shell source tools/env;echo $$dest_dir)
owner ?= $(shell source tools/env;echo $$owner)
work_dir ?= $(shell source tools/env;echo $$work_dir)
build_dir ?= $(shell source tools/env;echo $$build_dir)

uboot_dir ?= $(shell source tools/env;echo $$uboot_dir)
uboot_build ?= $(shell source tools/env;echo $$uboot_build)
uboot_config ?= $(shell source tools/env;echo $$uboot_config)

linux_dir ?= $(shell source tools/env;echo $$linux_dir)
linux_build ?= $(shell source tools/env;echo $$linux_build)
linux_config ?= $(shell source tools/env;echo $$linux_config)
linux_dtb ?= $(shell source tools/env;echo $$linux_dtb)
zimage ?= $(shell source tools/env;echo $$zimage)


onl_dir ?= $(shell source tools/env;echo $$onl_dir)
onl_root ?= $(shell source tools/env;echo $$onl_root)
onl_overlay ?= $(shell source tools/env;echo $$onl_overlay)

ONIE_USE_CACHE ?= TRUE

$(build_dir) :
	mkdir -p $(build_dir)

$(uboot_config) : $(build_dir)
	cd $(uboot_dir);make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm e530_24x2c_defconfig O=$(uboot_build)  

$(linux_config) : $(build_dir)
	cd $(linux_dir);touch .scmversion
	cd $(linux_dir);make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig O=$(linux_build)


onl_rebuild:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --pull --command "make -f auto.make rebuild"

onl_root:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_rootfs"
onl_root_onlpv2:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_rootfs"
onl_swi_onlpv2:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_swi"
onl_installer_onlpv2:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_installer"
onl_all:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_all"
onl_pack:
	cd $(onl_dir)/packages/platforms/cncr;git pull origin luojie
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_ctn4200"
onl_onlp:
	cd $(onl_dir);docker/tools/onlbuilder -9 --non-interactive --command "make -f auto.make onl_onlp"
$(onl_root) :
	make onl_root

onlfs: $(onl_root) $(onie_root)
	sudo chown -R $(owner):$(owner) $(onl_root)
	cd $(onl_overlay);for f in `find . -type f`;do dir=$(onl_root)/`dirname $$f`;mkdir -p $$dir;cp $$f $$dir;done
	cd $(onl_root);rm -rf init;ln -s /sbin/init .
	cd $(onl_root);sudo rm -f usr/bin/qemu-aarch64-static
	cd $(onl_root);sudo rm -rf sbin/hwclock
	cd $(onl_root);sudo ln -sf /bin/busybox sbin/hwclock
	cd $(onl_root);rm -f onie-syseeprom;sudo ln -sf /bin/busybox bin/onie-syseeprom
	sudo chown root:root -R $(onl_root)
	sudo chmod 7755 $(onl_root)/usr/bin/passwd
	sudo chmod 7755 $(onl_root)/usr/bin/sudo
	sudo chmod 7755 $(onl_root)/bin/su
	cd $(onl_root);sudo find .| sudo cpio -o -H newc | sudo gzip -9 > $(build_dir)/onl_ramfs.cpio.gz
	sudo chown -R $(owner):$(owner) $(build_dir)/onl_ramfs.cpio.gz
	sudo chown -R $(owner):$(owner) $(onl_root)
	cd tools;mkimage -f uimage_linux4.19_onl_ramfs.its $(build_dir)/uImage_linux419_onl_ramfs
	cp $(build_dir)/uImage_linux419_onl_ramfs $(dest_dir)

lconf :
	cd $(linux_dir);./conf

uconf:
	cd $(uboot_dir);./conf
pull: 
	cd $(uboot_dir)
	git checkout master
	git pull origin master
	cd $(linux_dir)
	git checkout master
	git pull origin master
	cd $(onl_dir)
	git checkout master
	git pull origin master

all :
	make onl_all
