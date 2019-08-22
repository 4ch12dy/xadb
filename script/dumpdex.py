import json
import os
import sys
import frida

if len(sys.argv) > 1:
	app_pid = sys.argv[1]
	print("[Dumpdex]: You specail the pid "+app_pid)
	
device = frida.get_usb_device()
pkg_name = device.get_frontmost_application().identifier

# pid = device.spawn(pkg_name)

# if customize the pid, use this pid. Such as app has mutiple pid
if ('app_pid' in locals() or 'app_pid' in globals()) and app_pid:
	session = device.attach(int(app_pid))
else:
	session = device.attach(pkg_name)

script = session.create_script(open(open(os.path.expanduser("~/.xadb/rootdir")).read().strip() + "/script/agent.js").read())
script.load()

matches = script.exports.scandex()
for dex in matches:
    bs = script.exports.memorydump(dex['addr'], dex['size'])
    if not os.path.exists("./" + pkg_name + "/"):
        os.mkdir("./" + pkg_name + "/")
    open(pkg_name + "/" + dex['addr'] + ".dex", 'wb').write(bs)
    print("len: " + hex(dex['size']) + ", path: ./" + pkg_name + "/" + dex['addr'] + ".dex")
