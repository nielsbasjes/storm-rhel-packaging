storm-rhel-packaging
====================

Packaging for redhat and fedora style RPM installations, including init.d scripts, default configurations, and a .spec file for building an RPM.
These scripts have been rewritten to make building the rpms as easy as possible.

This includes monit scripts that go in /etc/monit.d/ if you so choose. This also gives storm a more cannonical fedora layout, with the storm working directories being in /var/opt/storm/(nimbus/supervisor/ui), logs going to /var/log/storm, and pid files being stored in /var/run/storm. Tweaks for config launches can be found in /etc/sysconfig/storm.

----------

Dependencies
============
NOTE: This have been tested on CentOS 6.4 64bit

ZeroMQ
------
You can get prebuild zeroMQ rpms for either the EPEL repository

    http://nl.mirror.eurid.eu/epel/6/i386/repoview/epel-release.html

or here

	http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-6/


Building
--------

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
	zeromq-devel

Running the build process
-------------------------
Simply type 

	make

Both storm and jzmq are downloaded and the rpms are built.

----------

Install Instructions
=====================
First make sure you have one of the ZeroMQ repos enabled.

	yum install storm-0.8.1-1.el6.x86_64.rpm jzmq-2.2.0-1.el6.x86_64.rpm

In order to run storm you also need to have zookeeper installed and running!
Storm is installed in /opt/storm/ and you can now continue with the regular configuration of storm.

Because you'll probably want to have storm running continously you can now do

	chkconfig storm-nimbus on
	service storm-nimbus start

	chkconfig storm-ui on
	service storm-ui start

	chkconfig storm-supervisor on
	service storm-supervisor start

