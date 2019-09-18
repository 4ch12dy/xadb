import json
import os
import sys
import frida
import time
import re


if len(sys.argv) <= 1:
	print("[Dumpdex]: you should pass pid/packageName")
	exit()
	
device = frida.get_usb_device()
pkg_name = device.get_frontmost_application().identifier
# check is package or pid

pattern = re.compile(r'^\d+$', re.I)
m = pattern.match(sys.argv[1])

if m:

	app_pid = sys.argv[1]
	print("[Dumpdex]: you specail the pid:" + app_pid)
	# if customize the pid, use this pid. Such as app has mutiple pid
	if ('app_pid' in locals() or 'app_pid' in globals()) and app_pid:
		session = device.attach(int(app_pid))
	else:
		session = device.attach(pkg_name)
else:
	pkg_name = sys.argv[1]
	print("[Dumpdex]: you specail the package name:" + pkg_name + ", so spawn it and sleep 50s for launch completely")
	
	pid = device.spawn(pkg_name)

	time.sleep(50);

	session = device.attach(pid)

script = session.create_script(open(open(os.path.expanduser("~/.xadb/rootdir")).read().strip() + "/script/agent.js").read())
script.load()

matches = script.exports.scandex()
for dex in matches:
    bs = script.exports.memorydump(dex['addr'], dex['size'])
    if not os.path.exists("./" + pkg_name + "/"):
        os.mkdir("./" + pkg_name + "/")
    open(pkg_name + "/" + dex['addr'] + ".dex", 'wb').write(bs)
    print("[Dumpdex]: DexSize=" + hex(dex['size']) + ", SavePath=./" + pkg_name + "/" + dex['addr'] + ".dex")
