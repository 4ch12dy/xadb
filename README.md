# xadb
Android逆向一键化操作脚本，一键开启调试(ida/gdb/lldb)，一键查看app、设备信息，一键脱壳等等

#### Install

- `git clone xadb_git_project;`
- `cd xadb` 
- `./install.sh the_android_sdk_path ` example:`./install.sh ~/xia0/android/sdk`
- If your shell is bash run: `source ~/.bash_profile`
- If your shell is zsh run :`source ~/.zshrc`

#### Command

```
adb device   [imei]                              show connected android device basic info 
adb app      [sign/so/pid/apk/debug/dump]        show current app, debug and dump dex  
adb xlog     [package]                           logcat just current app or special package 
adb debug    [ida/ida64,lldb/lldb64, gdb/gdb64]  open debug and setup ida/lldb/gdb debug enviroment 
adb frida/64 start frida server on device        		 
adb pcat     [remote-file]                       copy device file to local 
adb -h       show this help usage 
```

说明：adb兼容内置的所有命令

`mprop`只编译了64位的版本，若你为32位的设备，可以自行编译。

在source目录下面提供了mprop的源码及build脚本

 #### Screeshot

![adb-device](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-device.png?raw=true)



![adb-app](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-app.png?raw=true)



![adb-app-so](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-app-so.jpeg?raw=true)



![adb-app-sign](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-app-sign.png?raw=true)



![adb-app-apk](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-app-apk.png?raw=true)



![adb-debug-ida](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-debug-ida.jpeg?raw=true)



![adb-debug-gdb](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-debug-gdb.png?raw=true)



![adb-debug-lldb](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-debug-lldb.png?raw=true)



![adb-frida](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-frida.png?raw=true)



![adb-xlog](https://github.com/4ch12dy/xadb/blob/master/screenshot/adb-xlog.png?raw=true)

