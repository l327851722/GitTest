#!/bin/bash

TOPDIR=$PWD


if [ ! $build_command_version ]; then
        build_command_version=master
fi
if [ ! $user_binary_version ]; then
        user_binary_version=master
fi
if [ ! $uboot_version ]; then
        uboot_version=master
fi
if [ ! $kernel_version ]; then
        kernel_version=master
fi
if [ ! $rootfs_version ]; then
        rootfs_version=master
fi
if [ ! $app_version ]; then
        app_version=master
fi
if [ ! $update_app_version ]; then
        update_app_version=master
fi

if [ ! $admin_user ]; then
        #admin_user=autocruis
        admin_user=jenkins
fi

##################################  build command #############################################
if [ ! $build_command_remote ]; then
        build_command_remote=git@192.168.1.241:Dms_Master_Project/opt_command.git
fi
if [ ! $build_command_remote_name ]; then
        build_command_remote_name=opt_command
fi

###############################################################################################

##################################  user binary  ###################################################
if [ ! $user_binary_remote ]; then
        user_binary_remote=git@192.168.1.241:Dms_Master_Project/user_binary.git
fi
if [ ! $user_binary_remote_name ]; then
        user_binary_remote_name=user_binary
fi

###############################################################################################

##################################  uboot  ###################################################
if [ ! $uboot_remote ]; then
        uboot_remote=git@192.168.1.241:Dms_Master_Project/u-boot-xlnx-xilinx-v2017.3.git
fi
if [ ! $uboot_remote_name ]; then
        uboot_remote_name=u-boot-xlnx-xilinx-v2017.3
fi
if [ ! $uboot_config ]; then
        uboot_config=zynq_adas_v2.3_defconfig
fi
###############################################################################################


##################################  kernel  ###################################################
if [ ! $kernel_remote ]; then
        kernel_remote=git@192.168.1.241:Dms_Master_Project/linux-xlnx-xilinx-v2017.3.git
fi
if [ ! $kernel_remote_name ]; then
        kernel_remote_name=linux-xlnx-xilinx-v2017.3
fi
if [ ! $kernel_config ]; then
        kernel_config=zynq_adas_v2.3_defconfig
fi
###############################################################################################


##################################  rootfs  ###################################################
if [ ! $rootfs_remote ]; then
        rootfs_remote=git@192.168.1.241:Dms_Master_Project/rootfs.git
fi
if [ ! $rootfs_remote_name ]; then
        rootfs_remote_name=rootfs
fi
###############################################################################################


##################################  app  ######################################################
if [ ! $app_remote_name ]; then
        app_remote_name=avm_ahd_app
fi
if [ ! $app_remote ]; then
        app_remote=git@192.168.1.241:avm_ahd/avm_ahd_app.git
fi
################################################################################################

##################################  SystemUpdate app  ######################################################
if [ ! $update_app_remote_name ]; then
        update_app_remote_name=SystemUpdate
fi
if [ ! $update_app_remote ]; then
        update_app_remote=git@192.168.1.241:tianmai_adas/SystemUpdate.git
fi
################################################################################################

    echo -e "\033[33m PWD      \033[0m version:\033[31m$TOPDIR\033[0m"
    echo -e "\033[33m build_command      \033[0m version:\033[31m$build_command_version\033[0m"
    echo -e "\033[33m user_binary       \033[0m version:\033[31m$user_binary_version\033[0m"
    echo -e "\033[33m uboot             \033[0m version:\033[31m$uboot_version\033[0m"
    echo -e "\033[33m kernel            \033[0m version:\033[31m$kernel_version\033[0m"
    echo -e "\033[33m rootfs            \033[0m version:\033[31m$rootfs_version\033[0m"
    echo -e "\033[33m app               \033[0m version:\033[31m$app_version\033[0m"
    echo -e "\033[33m SystemUpdate_app  \033[0m version:\033[31m$update_app_version\033[0m"
    echo -e "\033[33m admin_user        \033[0m version:\033[31m$admin_user\033[0m"

uboot_bin_name=u-boot
kernel_bin_name=uImage
kernel_dtb_name=zynq-lvds
#app_bin=AVM_HS
system_update_app_bin=SystemUpdate

#kernel_mod_list='mii.ko asix.ko usbnet.ko fat.ko vfat.ko libcomposite.ko usb_f_rndis.ko u_ether.ko spi-mcu.ko spidev.ko'
kernel_mod_list='mii.ko asix.ko usbnet.ko fat.ko vfat.ko usb-storage.ko'
command_dir=$TOPDIR/command

build_command_dir=$TOPDIR
uboot_dir=$TOPDIR/../$uboot_remote_name
kernel_dir=$TOPDIR/../$kernel_remote_name
ubifs_dir=$TOPDIR/../$rootfs_remote_name
app_src_dir=$TOPDIR/../$app_remote_name
update_app_src_dir=$TOPDIR/../$update_app_remote_name

kernel_image_dir=$kernel_dir/arch/arm/boot
kernel_dtb_dir=$kernel_dir/arch/arm/boot/dts
app_bin_dir=$TOPDIR/../build_command/output/app

rootfs_dir=$ubifs_dir/rootfs_ubi
initramfs_dir=$ubifs_dir/Initramfs
ubifs_bin_dir=$ubifs_dir/result

nv_dir=$ubifs_dir/nv_ubi

binary_dir=$TOPDIR/../user_binary

ouput_dir=$TOPDIR/../build_command/output
install_dir=$ouput_dir/install
kernel_mod_dir=$ouput_dir/kernel_mod

tmp_dir=$TOPDIR/../build_command/tmp

rootfs_folder='bin dev etc home lib licenses lost+found mnt mnt/sdcard_fat mnt/sdcard_ext nfs_share opt proc root sbin sys tmp usr usr/app usr/nv var'

export app_version kernel_dir kernel_mod_dir  app_bin_dir ubifs_dir
#export app_src_dir app_remote_name  app_bin
export app_src_dir app_remote_name
export update_app_src_dir  update_app_remote_name  system_update_app_bin


#删除生成的二进制文件
clear_all()
{
        rm -rf $ouput_dir
        rm -rf $tmp_dir
        rm -f $ubifs_bin_dir/*
#	rm -rf $binary_dir
        make -C $uboot_dir clean
        make -C $kernel_dir clean
        echo "rm $ouput_dir"
        echo "rm $tmp_dir"
}


#命令运行状态提示
check_command_status()
{
        if [ $? -ne 0 ]; then
                echo -e "\033[31m$1 $2\033[0m build error!!!"
                exit 1
        fi
}


#检测目录，不存在时创建
detect_install_path()
{
        if [ ! -d $1 ]; then
                mkdir -p $1
                echo "creat folder "$1
        fi
}

cp_file()
{
        echo "#####################################################"
        detect_install_path $3
        cp $1/$2 $3
        echo -e "\033[31m$2\033[0m copy to $3"
        echo "#####################################################"
        printf "\n\n\n"
}

detect_rootfs_folder()
{
        for folder in $rootfs_folder
        do
                detect_install_path $rootfs_dir/$folder
				detect_install_path $initramfs_dir/$folder
        done
		if [ -d $initramfs_dir/dev ]; then
			cd $initramfs_dir/dev
			mknod -m 660 console c 5 1
			mknod -m 660 null c 1 3
			cd -
		fi
}

#检测目录是否为空, 非空时拷贝文件到目标目录
detect_file_cp()
{
        l_fileCount=`ls $1 | wc -l`
        echo "fileCount: ${l_fileCount}"
        if [ "$l_fileCount" -gt "0" ]; then
            cp -R $1 $2
            return 0
        else
            echo "$1 is empty..."
            return 1
        fi
}

get_git_version()
{
    branch=$1
    remote_git=$2
    target_path=$3
    current_pwd=`pwd`
    cd $target_path
    revsion=`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3`

    if [ "$branch"x == "$revsion"x ]; then
        echo -e "\033[32m $target_path  branch: $branch \033[0m"
        git reset --hard > /dev/null
        check_command_status
        git pull origin $branch
        check_command_status
		git log -n 1
        check_command_status

    else
        echo -e "\033[31m $target_path  branch: $revsion  change to  $branch \033[0m"

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            cd $target_path/..
            rm -rf $target_path
            check_command_status
            git clone  $remote_git $target_path
            check_command_status
            cd $target_path
            git checkout $branch
            check_command_status
			git log -n 1
            check_command_status
        else
            git branch
            git status

            echo -e "\033[31m are you sure checkout $branch and merge $revsion ?  \033[0m"
            read  -p "(yes/no):" ans_bin
            case $ans_bin in
            Y | y | yes | Yes )
                    echo "git checkout $branch"
                    git checkout $branch
                    git merge $revsion
                    check_command_status
					git log -n 1
                    check_command_status
            ;;
            * )
                    echo "please check git brank!"
                    exit 2
            ;;
            esac
        fi
    fi
    cd $current_pwd
}
#编译u-boot，并拷贝到ouput目录下
create_bootloader()
{

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]] && [[ ! -d $uboot_dir ]]; then
                git clone  $uboot_remote $uboot_dir
                echo "creat folder "$uboot_dir
        fi

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            get_git_version $uboot_version $uboot_remote $uboot_dir
            check_command_status
        fi

        cd $uboot_dir
        if [ ! -e "$uboot_dir/.config" ]; then
                make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $uboot_dir $uboot_config
                check_command_status u-boot config
        fi

        make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $uboot_dir -j16
        check_command_status $uboot_dir
        detect_install_path $tmp_dir
        . $command_dir/md5_detect.sh _FILE_ $uboot_dir $uboot_bin_name
        cp_file $uboot_dir $uboot_bin_name $install_dir
        mv $install_dir/$uboot_bin_name $install_dir/u-boot.elf
        check_command_status

        cd -
}

#编译kernel，并拷贝到ouput目录下
create_kernel()
{
        if [ ! -d $ubifs_dir ]; then
                git clone $rootfs_remote $ubifs_dir
                echo "creat folder "$ubifs_dir
        fi

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            get_git_version $rootfs_version $rootfs_remote $ubifs_dir
            check_command_status
        fi
        
        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]] && [[ ! -d $kernel_dir ]]; then
                git clone $kernel_remote $kernel_dir
                echo "creat folder "$kernel_dir
        fi

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            get_git_version $kernel_version $kernel_remote $kernel_dir
            check_command_status
        fi

        cd $kernel_dir
        if [ ! -e "$kernel_dir/.config" ]; then
                make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $kernel_dir $kernel_config
                check_command_status kernel config
        fi
        make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $kernel_dir  LOADADDR=0X00008000 $kernel_bin_name -j16
        check_command_status $kernel_dir
        detect_install_path $tmp_dir
        . $command_dir/md5_detect.sh _FILE_ $kernel_image_dir $kernel_bin_name
        cp_file $kernel_image_dir $kernel_bin_name $install_dir
        mv $install_dir/$kernel_bin_name $install_dir/$kernel_bin_name.bin
        check_command_status

        cd -
}

#编译devicetree，并拷贝到ouput目录下
create_devicetree()
{
        make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $kernel_dir ${kernel_dtb_name}.dtb
        detect_install_path $tmp_dir
        . $command_dir/md5_detect.sh _FILE_ $kernel_dtb_dir ${kernel_dtb_name}.dts
        cp_file $kernel_dtb_dir ${kernel_dtb_name}.dtb $install_dir
        mv $install_dir/${kernel_dtb_name}.dtb $install_dir/zynq-zed.bin
        check_command_status
}

#编译内核模块，并拷贝到ouput目录下
create_kernel_mod()
{
        detect_install_path $kernel_mod_dir
        detect_install_path $tmp_dir
        . $command_dir/create_module.sh
        check_command_status
}

#编译app，并拷贝到ouput/app目录下
create_app()
{


        if [ ! -d $app_src_dir ]; then
                git clone $app_remote $app_src_dir
                echo "creat folder "$app_src_dir
        fi
        if [ ! -d $update_app_src_dir ]; then
                git clone $update_app_remote $update_app_src_dir
                echo "creat folder "$update_app_src_dir
        fi

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            get_git_version $app_version $app_remote $app_src_dir
            check_command_status
        fi
        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            get_git_version $update_app_version $update_app_remote $update_app_src_dir
            check_command_status
        fi


        . $command_dir/create_app.sh all
        check_command_status
}

copy_binary2ubifs()
{
        if [ ! -d $binary_dir ]; then
                git clone $user_binary_remote $binary_dir
                echo "creat folder "$binary_dir
        fi

        if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
            get_git_version $user_binary_version $user_binary_remote $binary_dir
            check_command_status
        fi

        detect_install_path $tmp_dir
        detect_install_path $ubifs_bin_dir
        . $command_dir/md5_detect.sh _PATH_ $binary_dir binary

        #rm -rf $rootfs_dir/lib/modules
        #detect_file_cp $kernel_mod_dir/modules $rootfs_dir/lib
		rm -rf $nv_dir/modules
        detect_file_cp $kernel_mod_dir/modules $nv_dir
        

        detect_file_cp $binary_dir/audio $ubifs_dir/app_ubi
#	cp -R $binary_dir/audio $ubifs_dir/app_ubi

        detect_file_cp $binary_dir/lib   $ubifs_dir/app_ubi
#	cp -R $binary_dir/lib   $ubifs_dir/app_ubi

        detect_file_cp $binary_dir/model $ubifs_dir/app_ubi
#	cp -R $binary_dir/model $ubifs_dir/app_ubi

        detect_file_cp $binary_dir/userdata $ubifs_dir/app_ubi
#	cp -R $binary_dir/userdata $ubifs_dir/app_ubi



        if [ -e "$app_bin_dir/arm" ]; then
                cp_file $app_bin_dir arm   $ubifs_dir/app_ubi
                check_command_status
        fi
        if [ -e "$app_bin_dir/qt" ]; then
                cp_file $app_bin_dir qt   $ubifs_dir/app_ubi
                check_command_status
        fi

        detect_file_cp $binary_dir/config $ubifs_dir/app_ubi
#	cp $binary_dir/config/* $ubifs_dir/app_ubi

        #detect_file_cp $binary_dir/env $install_dir
        cp $binary_dir/env/*  $install_dir

        #detect_file_cp $binary_dir/fpga $install_dir
        cp $binary_dir/fpga/* $install_dir

        cp_file $build_command_dir/../build_command code_branch.txt    $install_dir
        check_command_status

        cp_file $binary_dir readme.txt $install_dir
        check_command_status

        echo "#####################################################"
        echo -e "\033[31m copy binary files !!!\033[0m"
        echo "#####################################################"

}

#创建rootfs.ubifs.bin  app.ubifs.bin，并拷贝到ouput/app目录下
create_ubifs()
{

        #if [ ! -d $ubifs_dir ]; then
        #        git clone $rootfs_remote $ubifs_dir
        #        echo "creat folder "$ubifs_dir
        #fi

        #if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
        #    get_git_version $rootfs_version $rootfs_remote $ubifs_dir
        #    check_command_status
        #fi
        detect_install_path $tmp_dir
        detect_install_path $app_bin_dir
        detect_install_path $ubifs_bin_dir
        detect_rootfs_folder

        copy_binary2ubifs
        check_command_status

        . $command_dir/md5_detect.sh _PATH_ $ubifs_dir ubifs
        cd $ubifs_dir
            ./TOP.sh
        cd -

        cp_file $ubifs_bin_dir rootfs.ubifs.bin $install_dir
        cp_file $ubifs_bin_dir app.ubifs.bin $install_dir
        cp_file $ubifs_bin_dir nv.ubifs.bin $install_dir

        echo "#####################################################"
        echo -e "\033[31m rootfs.tar.gz creat finish !!!\033[0m"
        echo "#####################################################"
}
#创建ouput/install/BOOT.BIN
create_pack()
{
        echo "#####################################################"
        if [ ! -d $install_dir ]; then

                echo -e "\033[31m$install_dir\033[0m is not exist !"
                exit 1
        fi
        . $command_dir/md5_detect.sh _PATH_ $install_dir install_path
        . $command_dir/PacketBoot.sh $install_dir
        check_command_status BOOT.BIN
        echo -e "\033[31m BOOT.BIN \033[0m create finish..."

        detect_install_path $install_dir/upgradepkg
        cp $install_dir/PLBOOT.BIN		$install_dir/upgradepkg
        cp $install_dir/uImage.bin		$install_dir/upgradepkg
        cp $install_dir/zynq-zed.bin		$install_dir/upgradepkg
        cp $install_dir/rootfs.ubifs.bin	$install_dir/upgradepkg
        cp $install_dir/app.ubifs.bin		$install_dir/upgradepkg
        cp $binary_dir/version/version.txt	$install_dir/upgradepkg
        cp $binary_dir/version/compat_desc.xml	$install_dir/upgradepkg
        cd $install_dir
                tar -czvf - upgradepkg | openssl des3 -salt -k 123456 -out upgradepkg.tar.gz
                check_command_status upgradepkg.tar.gz
                #sync
                #sleep 1
                #tar -zcf output.tar.gz *
        cd -
        echo -e "\033[31m upgradepkg.tar.gz \033[0m create finish..."
        echo "#####################################################"
}


#运行状态提示
echo_help()
{
        echo "execute : ./build.sh clean | all "
        echo "[clean	 ] :	remove output folder, clean tmp folder"
        echo "[all	 ] :	building u-boot, uImage, devicetree.dtb...to output folder"
}

echo "TOPDIR:"$TOPDIR

COMMAND=$1


######################## update user_binary ##############################
if [ ! -d $binary_dir ]; then
        git clone $user_binary_remote $binary_dir
        echo "creat folder "$binary_dir
fi

if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
    get_git_version $user_binary_version $user_binary_remote $binary_dir
    check_command_status
fi

##########################################################################

if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
    get_git_version $build_command_version $build_command_remote $build_command_dir
    check_command_status
fi

if [ "$COMMAND" == "clean" ]; then
        clear_all $COMMAND
elif [ "$COMMAND" == "all" ]; then
        detect_install_path $install_dir
        create_bootloader
        create_kernel
        create_devicetree
        check_command_status create_devicetree
        create_kernel_mod
        create_app
        create_ubifs
        create_pack
else
        echo_help
fi

