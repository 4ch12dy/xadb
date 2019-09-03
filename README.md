# xadb
[English README](./README-EN.md)



Android逆向自动化操作脚本，一键开启调试(ida/gdb/lldb)，一键查看app、设备信息，一键脱壳等等

#### 安装

- 建议使用git方式下载项目，直接下载zip包会导致不能更新

  `git clone xadb_git_project` 

- 切换到xadb项目目录：`cd xadb` 

- 运行里面的安装脚本，需指定sdk路径，若不指定，则选择AndroidStudio默认的sdk路径

  `./install.sh the_android_sdk_path ` 例如:`./install.sh ~/xia0/android/sdk`

- 如果你是bash的终端环境则运行

   `source ~/.bash_profile`

- 如果你是zsh的终端环境则运行

  `source ~/.zshrc`




#### 重要更新

- [2019/08/22] # xadb集成第一代壳的脱壳功能（power by hluwa）

- [2019/09/03] # xadb增加了对Windows在MINGW64 shell执行环境的支持（若有bug，请issue）

  

#### 支持的命令

> 说明：adb兼容内置的所有命令。在分别在pixel2 Android8 和pixel3 Android9上面测试通过。
>
> mprop 只编译了64位的版本，若你为32位的设备，可以自行编译。
>
> 在source目录下面提供了mprop的源码及build脚本

**关于脱壳，之前基于frida的脱壳脚本只能脱一代壳且兼容性不高，就暂时没放出来。如果有大佬有比较好的方式，可以pr或者联系我完善下这部分。**

```
adb device   [imei]                              show connected android device basic info 
adb app      [sign/so/pid/apk/debug/dump]        show current app, debug and dump dex  
adb xlog     [package]                           logcat just current app or special pid 
adb debug    [ida/ida64,lldb/lldb64, gdb/gdb64]  open debug and setup ida/lldb/gdb debug enviroment 
adb frida/64 start frida server on device        		 
adb pcat     [remote-file]                       copy device file to local 
adb pstree   show the process tree of device     		 
adb sign     [local-apk-file]                    show sign of local apk file 
adb agent    [clean/reinstall]                   clean caches and reinstall agent 
adb -h       show this help usage               		 
adb update   update xadb for new version!
```

- adb device 

  获取一些设备的基本信息：品牌、imei、支持的架构、系统版本、sdk版本、wifi地址、是否开启调试？等

- adb app [sign/so/pid/apk/debug/dump/screen]

  这个命令主要获取当前运行的app一些基本信息。当直接运行`adb app`时候会得到如下信息

  ```
  app=com.tencent.mm
  pid=11574 11607
  activity=com.tencent.mm/com.tencent.mm.plugin.account.ui.LoginPasswordUI
  appdir=/data/app/com.tencent.mm-2YcjHxlY7eF18ihMCYbVEw==
  datadir=/data/user/0/com.tencent.mm
  ```

  常见的包名、所有进程号、当前activity、app路径、沙盒路径

  这个命令还支持子命令，这些命令都是对当前app的操作。

  - **adb app sign**:获取当前app的签名信息
  - **adb app so**:获取当前app的so内存布局
  - **adb app apk**:获取当前app的apk文件到本地
  - **adb app screen**:获取当前屏幕截图
  - **adb app debug**:以后台启动模式开启当前app调试
  - **adb app dump**:针对当前app的dex脱壳。

- adb xlog [package]

  获取当前app的日志，或后面可以加一个包名指定app的日志

- adb debug [ida/ida64,lldb/lldb64, gdb/gdb64]

  开启Android的调试环境，自动打开全局调试选项以及启动对应的调试服务端。其中ida还可以指定端口调试：adb debug ida 23333。默认为23946端口

- adb frida/frida64

  启动frida的服务端，暂时需要根据app来选择32位还是64的服务端。后面可以优化为自动选择

- adb pcat  [remote-file] 

  获取一个手机端上任意路径的文件。

- adb pstree

  显示手机端上的进程树情况，清晰发现进程以及其子进程关系

- adb -h

  获取xadb的用法帮助信息

- adb update

  从github更新xadb版本，获取最新的特性。

  

#### 项目核心开发人员

- [xia0](https://github.com/4ch12dy)
- [hluwa](https://github.com/hluwa)



#### 更新

- 2019-08-04/支持获取进程树的命令: `adb pstree`

  ```
  |\
  |  1 root init
  |  |\
  |  |  567 root init subcontext u:r:vendor_init:s0 9
  |  |\
  |  |  568 root init subcontext u:r:vendor_init:s0 10
  |  |\
  |  |  569 root ueventd
  |  |\
  |  |  582 logd logd
  |  |\
  |  |  583 system qseecomd
  |  |   \
  |  |    606 system qseecomd
  |  |\
  |  |  585 system android.hardware.keymaster@4.0-service-qti
  |  |\
  |  |  586 system vndservicemanager /dev/vndbinder
  |  |\
  |  |  587 hsm citadeld
  ...
  ```

- 2019-08-05/添加对ida调试自定义端口的支持

  用法:

  - `adb debug ida 23333` 设置调试端口为23333

  - `adb debug ida` 默认以23946位调试端口

  


#### 截图

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



