# isems-router

This repository contains the Linux software tools that work as a companion for the Freifunk-Open-MPPT-Solarcontroller. They are supposed to be installed on a router running OpenWRT. For your convenience, they come as a package, integrated in LUCI, the default Web-User-Interface of OpenWRT.

This package is supposed to go upstream into the LUCI repository at one point. Until then, you can get it here. Stay tuned for updates, as we are heading for adding more features.

## 

	Package: luci-app-ffopenmppt
	Depends: libc, luci-app-statistics, luci-app-freifunk-widgets, collectd-mod-exec
	License: Apache-2.0
	Section: luci
	Architecture: all
	Installed-Size: 7387
	Filename: luci-app-ffopenmppt-1_all.ipk
	Size: 8173
	SHA256sum:8f846a9c72026d49c7f8efee0ed230f89d9f22b13611e3fee3a124d56aa90774
	Description:  LuCI app for Independent Solar Energy Mesh System
	
As you can see, the package needs *luci-app-statistics*, *luci-app-freifunk-widgets* and *collectd-mod-exec*. Install these from the packet repository that your existing firmware already uses. You can do this either from the *opkg* packet installation web interface in LUCI, if your firmware has it – or the OpenWRT command line via SSH.

	opkg update
	opkg install luci-app-statistics
	opkg install luci-app-freifunk-widgets
	opkg install collectd-mod-exec

After you have finished doing this, download the package luci-app-ffopenmppt into the /tmp directory manually and install it.

	cd /tmp
	wget  *packet-url*
	opkg install luci-app-ffopenmppt-and_so_on
	
You are probably going to use the build-in serial port of the router to communicate with the Freifunk-Open-MPPT. By default, the serial port is used as a serial log-in port, usually for device debugging purposes. The OpenWRT package management system does not allow us to automatically overwrite this setting. We could do this with some trickery, but people would probably get upset if we disable their debugging interface without telling them about it. Hence, you have to *disable* the serial port login console of the router manually, by editing */etc/inittab* with **vi**, the default text editor of OpenWRT.

On the command line type:

	vi /etc/inittab

Move the cursor down to the beginning of the line containing *askconsole*. 

Press the **i**-key.

Add the *#*-sign to the beginning of the line. It should finally look exactly like this:

	::sysinit:/etc/init.d/rcS S boot
	::shutdown:/etc/init.d/rcS K shutdown
	#::askconsole:/usr/libexec/login.sh

Don't change anything else, this file is required to start the system. If it is malformed, the system will not start.

Press the *Escape* key.
Type **:wq**
Press *RETURN*

While you are here, check whether the command **stty** is available. If not, install coreutils-stty from the package repository of your firmware.

Now reboot the device.

After it is up and running, log in to the web interface. In the Admin interface, there is a new section named **Solar-Power**.

Check the settings of battery size, solar module power, power consumption and serial port. If you the serial port is incorrect, you won't see any data. The build in port is likely either **ttyS0** or **ttyATH0**, if you use a USB serial port dongle **ttyUSB0**.
