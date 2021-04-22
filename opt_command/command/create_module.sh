#!/bin/sh

KERNEL_PATH=$kernel_dir

MOD_PATH=$kernel_mod_dir/lib
ROOTFS_MOD_PATH=$kernel_mod_dir/modules

#MOD_FILE='configfs.ko libcomposite.ko u_ether.ko  usb_f_rndis.ko gspca_main.ko gspca_zc3xx.ko mii.ko libphy.ko asix.ko usbnet.ko vfat.ko fat.ko pl_intr.ko'
#MOD_FILE='configfs.ko libcomposite.ko u_ether.ko  usb_f_rndis.ko gspca_main.ko gspca_zc3xx.ko pl_intr.ko
#	mii.ko libphy.ko asix.ko usbnet.ko fat.ko vfat.ko rt2800lib.ko rt2800usb.ko rt2x00lib.ko rt2x00usb.ko
#	rtl8xxxu.ko rtl8192c-common.ko rtl8192cu.ko rtl_usb.ko rtlwifi.ko ip_tunnel.ko ipip.ko tunnel4.ko cfg80211.ko mac80211.ko '

MOD_FILE=$kernel_mod_list #'mii.ko asix.ko usbnet.ko fat.ko vfat.ko'

rm -rf $MOD_PATH $ROOTFS_MOD_PATH
mkdir -p $ROOTFS_MOD_PATH

echo $MOD_PATH
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $KERNEL_PATH modules -j16
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- -C $KERNEL_PATH modules_install INSTALL_MOD_PATH=$kernel_mod_dir -j16

echo "#####################################################"
if [ "$MOD_FILE"x == ""x ]; then
        echo "cp -R -d $MOD_PATH/modules/4.9.0-xilinx+ $ROOTFS_MOD_PATH"
        cp -R -d $MOD_PATH/modules/4.9.0-xilinx+ $ROOTFS_MOD_PATH

else


for driver_mod in $MOD_FILE
do
        MOD_NAME=$driver_mod
        find $MOD_PATH -type f -name "$MOD_NAME" -exec cp {} $ROOTFS_MOD_PATH \;
        find $MOD_PATH -type f -name "$MOD_NAME" -exec echo -e "\033[31m$MOD_NAME\033[0m copy to $ROOTFS_MOD_PATH" \;

done

fi

chmod 0775 $ROOTFS_MOD_PATH/* -R
echo "#####################################################"
printf "\n\n\n"



