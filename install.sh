#!/bin/bash
shell_root_dir=$(pwd)
shell_file_name="xadb.sh"
shell_file="$shell_root_dir/$shell_file_name"

bash_profile=$HOME"/.bash_profile"
zsh_profile=$HOME"/.zshrc"
mingw_profile="$HOME/.bash_profile"

#Please Set the Android SDK Path
###############################
ANDROID_SDK_PATH=""
ADB_PATH=""
###############################

echo "==== install xadb ===="

function check_sdk_path(){
	sdk_path=$1
	if [[ -f "$sdk_path/platform-tools/adb" ]];then
		echo "[+] found adb, continue!"
	elif [[ -n $ADB_PATH ]];then
		echo "[+] found adb, continue!"
	else
		echo "[-] not Found adb, please check the Android SDK path."
		exit
	fi
}

if [[ -e "~/Library/Android/sdk" ]];then
	ANDROID_SDK_PATH=~/Library/Android/sdk
fi

if [[ -n "$1" ]];then 
	ANDROID_SDK_PATH=$1
elif [[ -e $(which adb) ]]; then
	ADB_PATH=$(which adb)
elif [[ -e ~/Library/Android/sdk ]];then
	ANDROID_SDK_PATH=~/Library/Android/sdk
else
	echo "[-] you should set the Android SDK path."
	exit
fi

check_sdk_path $ANDROID_SDK_PATH

if [[ ! -d ~/.xadb ]]; then
	mkdir -p ~/.xadb
fi

echo "[*] create xadb support file"
echo "$shell_root_dir" > ~/.xadb/rootdir
echo "$ANDROID_SDK_PATH" > ~/.xadb/sdk-path
echo "$ADB_PATH" > ~/.xadb/adb-path

if [[ "$SHELL" = "/bin/zsh" ]]; then

	sh_profile=$zsh_profile

elif [[ "$SHELL" = "/bin/bash" ]]; then

	sh_profile=$bash_profile

elif [[ "$SHELL" = "/usr/bin/bash" ]]; then
	isMINGW=`uname -a  | grep -q MINGW && echo "1" || echo "0"`
	if [[ $isMINGW = "1" ]]; then
		sh_profile=$mingw_profile
	fi
	
else
	echo "[-] not support shell:$SHELL"
	exit
fi

echo "[+] detect current shell profile: $sh_profile"

# add xadb.sh to shell_profile
echo "[*] add \"source $shell_file\" to $sh_profile"
sed -i "" '/source.*xadb\.sh/d' $sh_profile 2>/dev/null
echo -e "\nsource $shell_file" >> $sh_profile

# done 
echo "[+] install finished, you can re-source $sh_profile or open a new terminal"
echo "======================"