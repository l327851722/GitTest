#!/bin/sh

detect_install_path()
{
	if [ ! -d $1 ]; then 
		mkdir -p $1 
		echo "creat folder "$1
	fi
}

detect_compile_result()
{
	
	if [ $? -eq 0 ]; then
		echo -e "\033[32m$1\033[0m compile succeed..."
		return 0
	else
		echo -e "\033[31m$1\033[0m compile is error !"
		return 1
	fi
}

check_src_update()
{
	. $command_dir/md5_detect.sh _PATH_ $1 $2
	if [ $? -eq 0 ]; then
		echo -e "\033[32m$2 source folder\033[0m no changed..."
		return 0
	else
		echo -e "\033[31m$2 source folder\033[0m changed !"		
		return 1
	fi
}

check_cmd_result()
{
        if [ $? -eq 0 ]; then
                echo -e "\033[32m$2 command success \033[0m ..."
        else
                echo -e "\033[31m$2 command failse  \033[0m !"             
        	exit 1        
        fi
}

copy_taget()
{
	echo "#####################################################"
	cp $1/$2 $app_bin_dir
	echo -e "\033[31m$2\033[0m copy to $app_bin_dir"
	echo "#####################################################"
	printf "\n\n\n"
}

compile_src()
{	
        detect_install_path $app_bin_dir
        taget=$1
        if [ "$taget" == "$app_remote_name" ]; then

                detect_install_path $app_src_dir/build
                check_src_update $app_src_dir $taget
                cd $app_src_dir/build
                qmake $app_src_dir/AVM_HS.pro
                check_cmd_result
                make -j16
                check_cmd_result
                #copy_taget $app_src_dir/build $app_bin
                copy_taget $app_src_dir/build/arm arm
                copy_taget $app_src_dir/build/qt qt
                cp -R $app_src_dir/arm/result $ubifs_dir/app_ubi
                cp -R $app_src_dir/arm/line $ubifs_dir/app_ubi
                cp -R $app_src_dir/arm/car $ubifs_dir/app_ubi
                cd -
        else
                check_src_update $update_app_src_dir/source $taget
                make -C $update_app_src_dir/source
                check_cmd_result
                copy_taget $update_app_src_dir/source $system_update_app_bin
        fi
}

clean_src()
{
        clean_taget=$1
        if [ "$clean_taget" == "$app_remote_name" ]; then
                make -C $app_src_dir clean
        else
                make -C $update_app_src_dir/source clean
        fi
}

echo_help()
{
        echo "execute : ./creat_app.sh dms_rev2.0_face_recognize"
        echo "[all] :	building project dms_rev2.0_face_recognize"
}



if [ "$1" == "all" ]; then
    compile_src $app_remote_name
    compile_src $update_app_remote_name
elif [ "$1" == "clean" ]; then
    clean_src $app_remote_name
    clean_src $update_app_remote_name
else
	echo_help
fi

