#!/bin/bash

COMMAD=$1
OPT_COMMAD=$PWD/../opt_commad
source $PWD/code_branch.txt

export build_commad_version
export uboot_version
export kernel_version
export dtb_version
export rootfs_version
export app_version
export update_app_version

echo $OPT_COMMAD

if [[ `whoami` == $admin_user ]] || [[ `whoami` == "root" ]]; then
    if [  -d $OPT_COMMAD ]; then
            rm -rf $OPT_COMMAD
            echo "rm  $OPT_COMMAD"
    fi
    git clone git@192.168.1.241:dms_v3.0/opt_commad.git $OPT_COMMAD
fi

if [  -d $OPT_COMMAD ]; then
    echo "./build.sh all"
    cd $OPT_COMMAD
    git checkout $build_commad_version
    source build.sh $COMMAD
    cd -

else
    echo "building false..."
    exit 1;
fi
