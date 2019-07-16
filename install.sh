#!/bin/bash
shell_root_dir=$(pwd)
shell_file_name="xadb.sh"
shell_file=$shell_root_dir"/"$shell_file_name

bash_profile=$HOME"/.bash_profile"
zsh_profile=$HOME"/.zshrc"

#Please Set the Android SDK Path
###############################
ANDROID_SDK_PATH=""
###############################

function xlog(){
	echo "[log]: "$1
}

function checkSDKPath(){
	sdk_path=$1
	if [[ -f "$sdk_path/platform-tools/adb" ]];then
		xlog "Found adb, Continue!"
	else
		xlog "Not Found adb, Please Check the Android SDK Path."
		exit
	fi
}

if [[ -n "$1" ]];then 
	ANDROID_SDK_PATH=$1
	checkSDKPath $ANDROID_SDK_PATH
else
	xlog "You should Set the Android SDK Path."
	exit
fi

if [[ ! -d ~/.xadb ]]; then
	mkdir -p ~/.xadb
fi

echo "$shell_root_dir" > ~/.xadb/rootdir

echo "$ANDROID_SDK_PATH" > ~/.xadb/sdk-path

if [[ "$SHELL" = "/bin/zsh" ]]; then

	sh_profile=$zsh_profile

elif [[ "$SHELL" = "/bin/bash" ]]; then

	sh_profile=$bash_profile

else
	echo "Not Support shell:$SHELL"
	exit
fi


# add issh.sh to shell_profile
xlog "add \"source $shell_file\" to $sh_profile"

grep 'xadb.sh' $sh_profile > /dev/null
if [ $? -eq 0 ]; then
    xlog $sh_profile" has include "$shell_file_name" just source it."
else
    xlog "install..."
    echo -e "\nsource $shell_file" >> $sh_profile
fi

# source $sh_profile > /dev/null
xlog "Please Run command:source $sh_profile"