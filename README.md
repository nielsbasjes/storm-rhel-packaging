storm-rhel-packaging
====================

Packaging for redhat and fedora style RPM installations, including init.d scripts, default configurations, and a .spec file for building an RPM.
These scripts have been rewritten to make building the rpms as easy as possible.

This includes monit scripts that go in /etc/monit.d/ if you so choose. This also gives storm a more cannonical fedora layout, with the storm working directories being in /var/opt/storm/(nimbus/supervisor/ui), logs going to /var/log/storm, and pid files being stored in /var/run/storm. Tweaks for config launches can be found in /etc/sysconfig/storm.

----------

Building
========
NOTE: This have been tested on CentOS 6.4 64bit

ZeroMQ
------
First make sure this repository has been enabled for your rpm build system. This contains the zeromq and zeromq-devel rpms.

	http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-6/

and install the zeromq development libraries on your build system.
	
	yum install zeromq-devel

Java
-----
Make sure that javah is available. It was found that this tool is installed as part of the Oracle Java RPM but is not placed in the path. I chose to simply create the following symlink to resolve this:

    ln -s /usr/java/jdk1.7.0_25/bin/javah /usr/bin/javah

Build tools
-----------
You need the common tools for building software.
Atleast the following packages must be installed (incomplete list): 

	git
	autoconf
	automake
	make
	gcc-c++
	rpm-build

Running the build process
-------------------------
Simply type 

	make

Both storm and jzmq are downloaded and the rpms are built.

----------

Install Instructions
=====================
First make sure this repository has been enabled for your system. This contains the zeromq rpm.

	http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-6/

then run

	yum install storm-0.8.1-1.el6.x86_64.rpm jzmq-2.2.0-1.el6.x86_64.rpm


Because you'll probably want to have storm running continously you can now do

	chkconfig storm-nimbus on
	service storm-nimbus start

	chkconfig storm-ui on
	service storm-ui start

	chkconfig storm-supervisor on
	service storm-supervisor start

