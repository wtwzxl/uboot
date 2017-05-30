#!/bin/sh

option1="tc4_ubuntu"

sec_path="../CodeSign4SecureBoot/"
CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
ROOT_DIR=$(pwd)
CUR_DIR=${ROOT_DIR##*/}  #CUR_DIR 的值是iTop4412_uboot_scp  ##*/

case "$1" in
	clean)
		echo make clean
		make mrproper  #删除所有的编译生成文件、内核配置文件(.config文件)和各种备份文件
		;;  #相当于break   
	   #以上不执行
	*)  # *表示默认模式
			
		if [ ! -d $sec_path ] # -d 表示$sec_path为目录，则返回为真
		then
			echo "**********************************************"
			echo "[ERR]please get the CodeSign4SecureBoot first"
			echo "**********************************************"
			return
		fi

		if [ -z $1 ] 
                then	
			make itop_4412_android_config

		elif [ $1 = $option1 ]
                then
			make itop_4412_android_ubuntu_config
		else 
			make itop_4412_android_config   #执行这里 编译uboot时使用./create_uboot.sh 这个脚本
		fi
		
		make -j$CPU_JOB_NUM
		
		if [ ! -f checksum_bl2_14k.bin ]
		then
			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			echo "There are some error(s) while building uboot, please use command make to check."
			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			exit 0
		fi
		
		cp -rf checksum_bl2_14k.bin $sec_path
		cp -rf u-boot.bin $sec_path
		rm checksum_bl2_14k.bin
		
		cd $sec_path
		#./codesigner_v21 -v2.1 checksum_bl2_14k.bin BL2.bin.signed.4412 Exynos4412_V21.prv -STAGE2
		
		# gernerate the uboot bin file support trust zone
		#cat E4412.S.BL1.SSCR.EVT1.1.bin E4412.BL2.TZ.SSCR.EVT1.1.bin all00_padding.bin u-boot.bin E4412.TZ.SSCR.EVT1.1.bin > u-boot-iTOP-4412.bin
		cat E4412_N.bl1.SCP2G.bin bl2.bin all00_padding.bin u-boot.bin tzsw_SMDK4412_SCP_2GB.bin > u-boot-iTOP-4412.bin
		mv u-boot-iTOP-4412.bin $ROOT_DIR
		
		rm checksum_bl2_14k.bin
		#rm BL2.bin.signed.4412
		rm u-boot.bin

		echo 
		echo 
		;;
		
esac
