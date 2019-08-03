#!/bin/bash
#__   __             _____    ____  
#\ \ / /     /\     |  __ \  |  _ \ 
# \ V /     /  \    | |  | | | |_) |
#  > <     / /\ \   | |  | | |  _ < 
# / . \   / ____ \  | |__| | | |_) |
#/_/ \_\ /_/    \_\ |_____/  |____/ 

#android_dir="$xia0/android/"
XADB_ROOT_DIR=`cat ~/.xadb/rootdir`

ANDROID_SDK_PATH=`cat ~/.xadb/sdk-path`

ADB="$ANDROID_SDK_PATH/platform-tools/adb"

# If update.lock exsist : there is new version for updating. use adb update
XADB_UPDATE_LOCK_FILE="$HOME/.xadb/update.lock"

# last-check-update.time : the last timestamp of checking update
XADB_LAST_CHECKUPDATE_TIMEFILE="$HOME/.xadb/last-check-update.time"

function XADBILOG(){

	echo -e "\033[32m[I]:$1 \033[0m"
}

function XADBELOG(){
	
	echo -e "\033[31m[E]:$1 \033[0m"
	
}

function XADBDLOG(){
	echo "[DEBUG]:$1" > /dev/null
}

function XADBTimeNow(){
	now=$(date "+%Y%m%d-%H:%M:%S")
	echo $now
}


function XADBCheckUpdate(){
	if [[ ! -f $XADB_LAST_CHECKUPDATE_TIMEFILE ]]; then 

		XADBDLOG "XADB_LAST_CHECKUPDATE_TIMEFILE Not Exsist."
		sh -c "cd $XADB_ROOT_DIR;git pull --dry-run | grep -q -v 'Already up-to-date.' && (touch $XADB_UPDATE_LOCK_FILE)"
		echo `date '+%s'` > $XADB_LAST_CHECKUPDATE_TIMEFILE

	else
		XADBDLOG "XADB_LAST_CHECKUPDATE_TIMEFILE Exsist."
		lastTimestamp=`cat $XADB_LAST_CHECKUPDATE_TIMEFILE`
		nowTimestamp=`date '+%s'`
		oneDayTimestamp=86400
		needTimestamp=`expr $nowTimestamp - $lastTimestamp`
		# echo $lastTimestamp $nowTimestamp $needTimestamp
		# Last check update is one day ago?
		if [[ $needTimestamp >  $oneDayTimestamp ]]; then 
			sh -c "cd $XADB_ROOT_DIR;git pull --dry-run | grep -q -v 'Already up-to-date.' && (touch $XADB_UPDATE_LOCK_FILE)"
			echo `date '+%s'` > $XADB_LAST_CHECKUPDATE_TIMEFILE
		fi
	fi


	if [[ -f $XADB_UPDATE_LOCK_FILE ]]; then

		XADBILOG "XADB has updated! Run \"adb update\" get new version :)"
	fi

	XADBDLOG "Update Check Done!"
}


function XADBCheckxia0(){
	if [[ "$1" = "clean" ]]; then
		$ADB -d shell "[ -d /sdcard/xia0 ] && rm -fr /sdcard/xia0"
		return
	fi

	script="[ -d /sdcard/xia0 ] || (mkdir -p /sdcard/xia0)"
	$ADB -d shell $script

	ret=`$ADB -d shell "[ -d /sdcard/xia0/frida ] && echo 1 || echo 0"`
	if [[ "$ret" = "0" ]]; then
		$ADB -d push "$XADB_ROOT_DIR/frida" /sdcard/xia0
	fi

	ret=`$ADB -d shell "[ -d /sdcard/xia0/tools ] && echo 1 || echo 0"`
	if [[ "$ret" = "0" ]]; then
		$ADB -d push "$XADB_ROOT_DIR/tools" /sdcard/xia0
	fi

	ret=`$ADB -d shell "[ -d /sdcard/xia0/debug-server ] && echo 1 || echo 0"`
	if [[ "$ret" = "0" ]]; then
		$ADB -d push "$XADB_ROOT_DIR/debug-server" /sdcard/xia0
	fi

}
	
function xadb(){

	# adb app [command] :show some app info 
	if [ "$1" = "app" ];then
		case $2 in
			package )
				APPID=`xadb shell dumpsys window | grep -i  mCurrentFocus | awk -F/ '{print $1}' | awk '{print $NF}'`
				if [[ "$APPID" = "Waiting" ]]; then
					APPID=`xadb shell dumpsys window | grep -i  mCurrentFocus | awk '{print $6}' | awk -F} '{print $1}'`
				fi
					
				echo $APPID
				;;

			activity )
				xadb shell dumpsys window | grep -i  mCurrentFocus
				;;

			pid )
				APPID=`xadb app package`
				APPPID=`xadb shell ps | grep  "$APPID" | awk '{print $2}'`
				echo $APPPID
				;;
				
			debug )
				activity=`xadb app activity | awk '{print $3}' | awk -F} '{print $1}'`
				xadb shell am start -D -n $activity
				sleep 2
				pid=`xadb app pid`
				xadb forward tcp:8700 jdwp:$pid

				;;

			# get apk file from device
			apk )
				if [ -z "$3" ]; then
					APP_ID=`xadb app package`

				else
					APP_ID=$3
				fi

				local_apk_file=`xadb app apk_in $APP_ID`

				XADBILOG "The APK File From Device:$local_apk_file"
				;;

			apk_in )
				if [ -z "$3" ]; then
					APP_ID=`xadb app package`

				else
					APP_ID=$3
				fi

				if [[ "$APP_ID" =~ "StatusBar" ]];then
					return
				fi

				base_apk=`xadb shell pm path $APP_ID | awk -F: '{printf $2}'`

				now=`XADBTimeNow`

				xadb pull $base_apk $APP_ID-$now.apk 1>/dev/null
				current_dir=`pwd`
				echo "$current_dir/$APP_ID-$now.apk"
				;;
			sign )
				if [ -z "$3" ]; then
					APP_ID=`xadb app package`

				else
					APP_ID=$3
				fi

				apk_file=`xadb app apk_in $APP_ID`

				if [ -z "$apk_file" ]; then
					XADBELOG "$APP_ID apk file can not copy from device"
					return
				fi
				SIGN_RSA=`unzip -l $apk_file | grep "META-INF.*\.RSA" | awk  '{printf $4}'`
				# echo $SIGN_RSA
				unzip -p $apk_file $SIGN_RSA | keytool -printcert
				rm $apk_file
				;;

			info )
				if [ -z "$3" ]; then
					APP_ID=`xadb app package`

				else
					APP_ID=$3
				fi
				xadb shell dumpsys package $APP_ID
				;;
			# get cureet screenshot 
			screen )
				xadb shell screencap -p > screen.png
				;;

			# dump current app so sharelib
			so|dumpso )
				if [ -z "$3" ]; then
					APPPID=`xadb app pid`

				else
					APPPID=$3
				fi

				APPID=`adb app package`
				XADBILOG "============================[PID=$APPPID PACKAGE:$APPID]=================================="
				xadb shell "su -c 'cat /proc/$APPPID/maps'" | grep '\.so'
				;;
			dump )
				# arm / arm64
				echo "Dex dump is developing,please wait..."
				# python "$android_dir/frida/frida_dump.py" -p $APPID -a $ARCH -v $OSVER
				;;
			*)
				APPID=`xadb app package`
				APPPID=`xadb app pid`
				APPDIR=`xadb app info | grep codePath`
				APPDIR=${APPDIR##*codePath=}
				APPDATADIR=`xadb app info | grep dataDir`
				APPDATADIR=${APPDATADIR##*dataDir=}
				echo -e "app=$APPID\npid=$APPPID\nappdir=$APPDIR\ndatadir=$APPDATADIR"
				;;
		esac

		return
	fi
	
	# show device basic info
	if [ "$1" = "device" ];then
		case $2 in
			imei )
				imei=`xadb shell service call iphonesubinfo 1 | awk -F "'" '{print $2}' | sed '1 d' | tr -d '.' | awk '{print}' ORS=`
				echo "$imei"
				;;
			
			*)
				model=`xadb shell getprop ro.product.model`
				serialno=`xadb shell getprop ro.serialno`
				brand=`xadb shell getprop ro.product.brand`
				manufacturer=`xadb shell getprop ro.product.manufacturer`
				abilist=`xadb shell getprop ro.product.cpu.abilist`
				imei=`xadb device imei`
				sdk_api=`xadb shell getprop ro.build.version.sdk`
				os_ver=`xadb shell getprop ro.build.version.release`
				wifi_ip=`xadb shell ip addr show wlan0 | grep "inet\s" | awk -F/ '{printf $1}' | awk '{printf $2}'`
				debug=`xadb shell getprop ro.debuggable`

				printf "%-20s %-20s \n" "model" "$model"
				printf "%-20s %-20s \n" "brand" "$brand"
				printf "%-20s %-20s \n" "manufacturer" "$manufacturer"
				printf "%-20s %-20s \n" "abilist" "$abilist"
				printf "%-20s %-20s \n" "sdk" "$sdk_api"
				printf "%-20s %-20s \n" "wifi ipv4" "$wifi_ip"
				printf "%-20s %-20s \n" "os version" "$os_ver"
				printf "%-20s %-20s \n" "serialno" "$serialno"
				printf "%-20s %-20s \n" "imei" "$imei"
				printf "%-20s %-20s \n" "can debug?" "$debug"

			;;
		esac
		return
	fi

	# misc
	# if [ "$1" = "dumpdex" ]; then
	# 	xadb sudo "cp /sdcard/xia0/libnativeDump.so /system/lib/"
	# 	xadb sudo "chmod 777 /system/lib/libnativeDump.so"
	# 	return
	# fi

	# setup ida debug env
	if [[ "$1" =~ "debug" ]]; then
		# steps of debug apk
		echo "**********************************************************************************"
		echo "====>1.adb shell am start -D -n package_id/.MainActivity"
		echo "====>2.adb forward tcp:8700 jdwp:pid"
		echo "====>3.jdb -connect \"com.sun.jdi.SocketAttach:hostname=localhost,port=8700\""
		echo "====>[gdb]$ target remote :23946"
		echo "====>[gdb]$ handle SIG32 nostop noprint"
		echo "====>[lldb]$ platform select remote-android"
		echo "====>[lldb]$ platform connect unix-abstract-connect:///data/local/tmp/debug.sock"
		echo "====>[lldb]$ process attach --pid=14396 or platform process attach -p 8098"
		echo "**********************************************************************************"

		# 判断是否开启了调试
		isdebug=`xadb shell getprop ro.debuggable`
		if [[ "$isdebug" = "0" ]]; then
			XADBILOG "Not open debug, opening..."
			ret=`adb shell "[ -f /data/local/tmp/mprop ] && echo "1" || echo "0""`

			if [[ "$ret" = "0" ]]; then
				xadb sudo "cp /sdcard/xia0/tools/mprop /data/local/tmp/"
			fi
			xadb sudo "chmod 777 /data/local/tmp/mprop"
			xadb sudo "/data/local/tmp/mprop"
			xadb sudo "setprop ro.debuggable 1"
			xadb sudo "/data/local/tmp/mprop -r"
			xadb sudo "getprop ro.debuggable"
			xadb sudo "stop"
			sleep 2
			xadb sudo "start"
			sleep 5
		fi

		# kill all server if process exsist
		xadb kill android_server64
		xadb kill android_server
		xadb kill gdbserver
		xadb kill gdbserver64
		xadb kill lldb-server
		xadb kill lldb-server64

		case $2 in
			ida )
				# 默认为32bit app ida debug
				server=`adb shell "[ -f /data/local/tmp/android_server ] && echo "1" || echo "0""`

				if [[ "$server" = "0" ]]; then
					xadb sudo "cp /sdcard/xia0/debug-server/android_server /data/local/tmp/"
				fi
				
				xadb sudo "chmod 777 /data/local/tmp/android_server"
				
				xadb forward tcp:23946 tcp:23946

				xadb sudo "/data/local/tmp/android_server"
				;;
			ida64 )
				# 64bit app ida debug
				server64=`adb shell "[ -f /data/local/tmp/android_server64 ] && echo "1" || echo "0""`

				if [[ "$server64" = "0" ]]; then
					xadb sudo "cp /sdcard/xia0/debug-server/android_server64 /data/local/tmp/"
				fi
				
				xadb sudo "chmod 777 /data/local/tmp/android_server64"

				xadb forward tcp:23946 tcp:23946

				xadb sudo "/data/local/tmp/android_server64"
				return
				;;
			gdb )
				# 32bit app gdb debug
				pid=$3
				if [ -z "$pid" ]; then
					pid=`xadb app pid`
				fi

				server=`adb shell "[ -f /data/local/tmp/gdbserver ] && echo "1" || echo "0""`

				if [[ "$server" = "0" ]]; then
					xadb sudo "cp /sdcard/xia0/debug-server/gdbserver /data/local/tmp/"
				fi
				
				xadb sudo "chmod 777 /data/local/tmp/gdbserver"
				
				xadb forward tcp:23946 tcp:23946

				xadb sudo "/data/local/tmp/gdbserver :23946 --attach $pid"
				return
				;;
			gdb64 )
				# 64bit app gdb debug
				pid=$3
				if [ -z "$pid" ]; then
					pid=`xadb app pid`
				fi

				server64=`adb shell "[ -f /data/local/tmp/gdbserver64 ] && echo "1" || echo "0""`

				if [[ "$server64" = "0" ]]; then
					xadb sudo "cp /sdcard/xia0/debug-server/gdbserver64 /data/local/tmp/"
				fi
				
				xadb sudo "chmod 777 /data/local/tmp/gdbserver64"

				xadb forward tcp:23946 tcp:23946

				xadb sudo "/data/local/tmp/gdbserver64 :23946 --attach $pid"
				return
				;;

			lldb )
				server=`adb shell "[ -f /data/local/tmp/lldb-server ] && echo "1" || echo "0""`

				if [[ "$server" = "0" ]]; then
					xadb sudo "cp /sdcard/xia0/debug-server/lldb-server /data/local/tmp/"
				fi
				
				xadb sudo "chmod 777 /data/local/tmp/lldb-server"

				# xadb shell /data/local/tmp/lldb-server platform --server --listen unix-abstract:///data/local/tmp/debug.sock
				xadb sudo "/data/local/tmp/lldb-server platform --server --listen unix-abstract:///data/local/tmp/debug.sock"
				return
				;;

			lldb64 )
				server64=`adb shell "[ -f /data/local/tmp/lldb-server64 ] && echo "1" || echo "0""`

				if [[ "$server64" = "0" ]]; then
					xadb sudo "cp /sdcard/xia0/debug-server/lldb-server64 /data/local/tmp/"
				fi
				
				xadb sudo "chmod 777 /data/local/tmp/lldb-server64"

				# xadb shell /data/local/tmp/lldb-server64 platform --server --listen unix-abstract:///data/local/tmp/debug.sock
				xadb sudo "/data/local/tmp/lldb-server64 platform --server --listen unix-abstract:///data/local/tmp/debug.sock"
				;;
			* )
				XADBELOG "\"$2\" debug server not found."
				return 
				;;
		esac
		return
	fi

	if [[ "$1" =~ "frida" ]]; then
		# https://github.com/frida/frida/releases
		script="find /sdcard/xia0/frida -type f -name \"frida*arm\""
		server=`xadb shell $script | awk -F/ '{print $NF}'`

		script="find /sdcard/xia0/frida -type f -name \"frida*arm64\""
		server64=`xadb shell $script | awk -F/ '{print $NF}'`

		XADBILOG "Current frida-server version, for more version visit:[https://github.com/frida/frida/releases]"
		printf "[%5s]: %-50s\n" "arm" $server
		printf "[%5s]: %-50s\n" "arm64" $server64

		xadb kill $server
		xadb kill $server64

		xadb forward tcp:27042 tcp:27042

		if [[ "$1" = "frida64" ]]; then
			ret=`adb shell "[ -f /data/local/tmp/$server64 ] && echo "1" || echo "0""`

			if [[ "$ret" = "0" ]]; then
				xadb sudo "cp /sdcard/xia0/frida/$server64 /data/local/tmp/"
			fi

			xadb sudo "chmod 777 /data/local/tmp/$server64"
			xadb sudo "/data/local/tmp/$server64"
			return
		fi

		ret=`adb shell "[ -f /data/local/tmp/$server ] && echo "1" || echo "0""`

		if [[ "$ret" = "0" ]]; then
			xadb sudo "cp /sdcard/xia0/frida/$server /data/local/tmp/"
		fi

		xadb sudo "chmod 777 /data/local/tmp/$server"
		xadb sudo "/data/local/tmp/$server"

		return
	fi

	if [[ "$1" = "pcat" ]]; then
		filepath=$2
		filename=${filepath##*/}
		xadb shell su -c "cat $2" > $filename
		return
	fi

	# sudo 
	if [ "$1" = "sudo" ]; then
		cmd=$2
		XADBILOG "Run \"$cmd\""
		xadb shell su -c "$cmd"
		return
	fi

	# kill process by name
	if [[ "$1" = "kill" ]]; then
		process_name=$2
		live=`xadb sudo "ps" | grep $process_name | awk '{print $9}'`
		# echo $process_name
		if [[ -n "$live" && "$live" = "$process_name" ]]; then
			xadb sudo "killall -9 $process_name"
		fi
		return
	fi

	# show log of app
	if [ "$1" = "xlog" ];then
		if [ -z "$2" ]; then
			APPPID=`xadb app pid`
			xadb xlog $APPPID
			return
		fi

		APPPID=$2
		XADBILOG "============================[PID=$APPPID PACKAGE:$APPID]=================================="
		xadb logcat --pid=$APPPID
		return
	fi


	if [ "$1" = "update" ];then
		XADBDLOG "Run adb update"
		sh -c "cd $XADB_ROOT_DIR;git pull;"
		return
	fi

 	# usage 
	if [[  "$1" = "-h" ]]; then
		printf "adb %-8s %-35s %-20s \n" "device" "[imei]" "show connected android device basic info" 
		printf "adb %-8s %-35s %-20s \n" "app" "[sign/so/pid/apk/debug/dump]" "show current app, debug and dump dex "
		printf "adb %-8s %-35s %-20s \n" "xlog" "[package]" "logcat just current app or special package"
		printf "adb %-8s %-35s %-20s \n" "debug" "[ida/ida64,lldb/lldb64, gdb/gdb64]" "open debug and setup ida/lldb/gdb debug enviroment"
		printf "adb %-8s %-35s 		 \n" "frida/64" "start frida server on device"
		printf "adb %-8s %-35s %-20s \n" "pcat" "[remote-file]" "copy device file to local"
		printf "adb %-8s %-35s		 \n" "-h" "show this help usage"
		return
	fi

	$ADB -d $@
}

function adb(){
	device=`$ADB -d get-state 2>/dev/null`
	if [[ "$device" != "device" ]]; then
		XADBELOG "no device found, please check connect state"
		return
	fi
	XADBCheckUpdate
	XADBCheckxia0
	xadb $@
}