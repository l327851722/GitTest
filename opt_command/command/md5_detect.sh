#!/bin/sh
TYPE=$1
FILE_PATH=$2
FILE_NAME=$3
MD5_FILE_PATH=$tmp_dir
MD5_FILE=$MD5_FILE_PATH/$FILE_NAME".md5"
MD5_CHECK_FILE=$MD5_FILE_PATH/$FILE_NAME".md5.check"

md5_file_flag=1
find_file(){
	file_a=`find $FILE_PATH  -type f -name $FILE_NAME -print | xargs md5sum > $MD5_FILE`
	echo $file_a
}

find_path(){
	path_b=`find $FILE_PATH \( -path "*/.git" -o -path "*.o" \) -prune -o -type f -print | xargs md5sum > $MD5_FILE`
	echo $path_b
}

change()
{	
	if [ "$TYPE" == "_PATH_" ]; then
		change_info=`grep 'FAILED' $MD5_CHECK_FILE |awk -F':' '{print $1}'`
		echo -e "\033[31m$change_info\033[0m changed !"
		find_path
	elif [ "$TYPE" == "_FILE_" ]; then
		echo -e "\033[31m$FILE_NAME\033[0m changed !"
		find_file
	fi
	return 1
}

no_change()
{
	echo $FILE_PATH
	echo -e "\033[32m$FILE_NAME\033[0m no changed..."
	return 0
}

echo $FILE_PATH


if [ ! -d  $FILE_PATH ]; then
	echo -e "$FILE_PATH is not exist!!!\n\n\n"
	exit -1;
fi

if [ !  -f  $MD5_FILE -a "$TYPE" == "_PATH_" ]; then
	find_path
elif [ !  -f  $MD5_FILE -a "$TYPE" == "_FILE_" ]; then
	find_file
fi


rm $MD5_CHECK_FILE
md5sum -c $MD5_FILE > $MD5_CHECK_FILE    2>&1
if [ $? -eq 0 ]; then
	no_change
else
	change
fi





