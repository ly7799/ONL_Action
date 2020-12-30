SHELL=/bin/bash

onl_all :
	source setup.env;if [ -z "`netstat -tlun|grep :3142`" ];then apt-cacher-ng;fi;make arm64
onl_rootfs :
	source setup.env;if [ -z "`netstat -tlun|grep :3142`" ];then apt-cacher-ng;fi;cd builds/arm64;make --no-print-directory -s -C rootfs || exit 1;
onl_swi :
	source setup.env;if [ -z "`netstat -tlun|grep :3142`" ];then apt-cacher-ng;fi;cd builds/arm64;make --no-print-directory -s -C swi  || exit 1;
onl_installer :
	source setup.env;if [ -z "`netstat -tlun|grep :3142`" ];then apt-cacher-ng;fi;cd builds/arm64;make --no-print-directory -C installer  || exit 1;
onl_ctn4200 :
	source setup.env;if [ -z "`netstat -tlun|grep :3142`" ];then apt-cacher-ng;fi;cd packages;make package-onlp-arm64-cncr-ctn4200-r0_arm64
onl_onlp :
	source setup.env;if [ -z "`netstat -tlun|grep :3142`" ];then apt-cacher-ng;fi;cd packages;make package-onlp_arm64
rebuild :
	source setup.env;make rebuild
