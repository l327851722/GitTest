#!/bin/sh

echo "creat flash image file..."

RELEASE_DIR=$1
FLASH_IMG=BOOT.BIN

BS_SIZE=10
((BS_DATA=1<<$BS_SIZE ))
echo "BS_DATA = "$BS_DATA

PLBOOT_OFFSET_ADDR=0x40000
PLBOOT_BAK_OFFSET_ADDR=0x640000

ENV_OFFSET_ADDR=0xC40000

KERNEL_OFFSET_ADDR=0xD40000

DEVICETREE_OFFSET_ADDR=0x1740000

NV_OFFSET_ADDR=0x1840000

APP_OFFSET_ADDR=0x2C40000

echo "---------------------------------------------------------------"

FSBLBOOT_NAME=FSBLBOOT.BIN
FSBLBOOT_OFFSET=0

PLBOOT_NAME=PLBOOT.BIN
((PLBOOT_OFFSET		=$PLBOOT_OFFSET_ADDR	>>$BS_SIZE))
((PLBOOT_BAK_OFFSET	=$PLBOOT_BAK_OFFSET_ADDR>>$BS_SIZE))
#echo "PLBOOT_OFFSET = "$PLBOOT_OFFSET
#echo "PLBOOT_OFFSET = "$PLBOOT_BAK_OFFSET

ENV_NAME=ENV.BIN
((ENV_OFFSET		=$ENV_OFFSET_ADDR	>>$BS_SIZE))


KERNEL_NAME=uImage.bin
((KERNEL_OFFSET		=$KERNEL_OFFSET_ADDR	>>$BS_SIZE))


DEVICETREE_NAME=zynq-zed.bin
((DEVICETREE_OFFSET	=$DEVICETREE_OFFSET_ADDR	>>$BS_SIZE))

NV_NAME=nv.ubifs.bin
((NV_OFFSET		=$NV_OFFSET_ADDR	>>$BS_SIZE))


APP_NAME=app.ubifs.bin
((APP_OFFSET		=$APP_OFFSET_ADDR	>>$BS_SIZE))
#echo "ROOTFS_OFFSET = "$ROOTFS_OFFSET


rm $RELEASE_DIR/$FLASH_IMG


if [ -e "$RELEASE_DIR/$FSBLBOOT_NAME" ]; then
	dd if=$RELEASE_DIR/$FSBLBOOT_NAME 		of=$RELEASE_DIR/$FLASH_IMG seek=$FSBLBOOT_OFFSET		bs=$BS_DATA 
	printf "merge %s offset = 0x%x \n\n" $RELEASE_DIR/$FSBLBOOT_NAME $FSBLBOOT_OFFSET 
else
        printf "not exist %s \n\n" $RELEASE_DIR/$FSBLBOOT_NAME
	exit -1;
fi


if [ -e "$RELEASE_DIR/$PLBOOT_NAME" ]; then
	dd if=$RELEASE_DIR/$PLBOOT_NAME 		of=$RELEASE_DIR/$FLASH_IMG seek=$PLBOOT_OFFSET			bs=$BS_DATA
	dd if=$RELEASE_DIR/$PLBOOT_NAME 		of=$RELEASE_DIR/$FLASH_IMG seek=$PLBOOT_BAK_OFFSET		bs=$BS_DATA
	printf "merge %s offset = 0x%x \n" $RELEASE_DIR/$PLBOOT_NAME $PLBOOT_OFFSET_ADDR
	printf "merge %s offset = 0x%x \n\n" $RELEASE_DIR/$PLBOOT_NAME $PLBOOT_BAK_OFFSET_ADDR
else
        printf "not exist %s \n\n" $RELEASE_DIR/$PLBOOT_NAME
	exit -1;
fi

if [ -e "$RELEASE_DIR/$ENV_NAME" ]; then
	dd if=$RELEASE_DIR/$ENV_NAME 		of=$RELEASE_DIR/$FLASH_IMG seek=$ENV_OFFSET			bs=$BS_DATA
	printf "merge %s offset = 0x%x \n\n" $RELEASE_DIR/$ENV_NAME $ENV_OFFSET_ADDR 
else
        printf "not exist %s \n\n" $RELEASE_DIR/$ENV_NAME
	exit -1;
fi


if [ -e "$RELEASE_DIR/$KERNEL_NAME" ]; then
	dd if=$RELEASE_DIR/$KERNEL_NAME 		of=$RELEASE_DIR/$FLASH_IMG seek=$KERNEL_OFFSET			bs=$BS_DATA
	printf "merge %s offset = 0x%x \n" $RELEASE_DIR/$KERNEL_NAME $KERNEL_OFFSET_ADDR 
else
        printf "not exist %s \n\n" $RELEASE_DIR/$KERNEL_NAME
	exit -1;
fi


if [ -e "$RELEASE_DIR/$DEVICETREE_NAME" ]; then
	dd if=$RELEASE_DIR/$DEVICETREE_NAME 		of=$RELEASE_DIR/$FLASH_IMG seek=$DEVICETREE_OFFSET		bs=$BS_DATA
	printf "merge %s offset = 0x%x \n" $RELEASE_DIR/$DEVICETREE_NAME $DEVICETREE_OFFSET_ADDR
else
        printf "not exist %s \n\n" $RELEASE_DIR/$DEVICETREE_NAME
	exit -1;
fi

if [ -e "$RELEASE_DIR/$NV_NAME" ]; then
	dd if=$RELEASE_DIR/$NV_NAME			of=$RELEASE_DIR/$FLASH_IMG seek=$NV_OFFSET			bs=$BS_DATA
	printf "merge %s offset = 0x%x \n\n" $RELEASE_DIR/$NV_NAME $NV_OFFSET_ADDR
else
        printf "not exist %s \n\n" $RELEASE_DIR/$NV_NAME
	exit -1;
fi

if [ -e "$RELEASE_DIR/$APP_NAME" ]; then
	dd if=$RELEASE_DIR/$APP_NAME 			of=$RELEASE_DIR/$FLASH_IMG seek=$APP_OFFSET			bs=$BS_DATA
	printf "merge %s offset = 0x%x \n\n" $RELEASE_DIR/$APP_NAME $APP_OFFSET_ADDR
else
        printf "not exist %s \n\n" $RELEASE_DIR/$APP_NAME
	exit -1;
fi
echo "creat flash image file finish!!!!"
