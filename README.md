storm-rhel-packaging
====================

Packaging for redhat and fedora style RPM installations, including init.d scripts, default configurations, and a .spec file for building an RPM.
These scripts have been rewritten to make building the rpms as easy as possible.

This includes monit scripts that go in /etc/monit.d/ if you so choose. This also gives storm a more cannonical fedora layout, with the storm working directories being in /var/opt/storm/(nimbus/supervisor/ui), logs going to /var/log/storm, and pid files being stored in /var/run/storm. Tweaks for config launches can be found in /etc/sysconfig/storm.

----------

Dependencies
============
NOTE: This has only been tested on CentOS 6.4 64bit!


Building
--------

Java
-----
Make sure that javah is available. It was found that this tool is installed as part of the Oracle Java RPM but is not placed in the path. I chose to simply create the following symlink to resolve this:

    ln -s /usr/java/jdk1.7.0_25/bin/javah /usr/bin/javah

Build tools
-----------
You need the common tools for building software.
At least the following packages must be installed (incomplete list): 

    git
    autoconf
    automake
    make
    gcc-c++
    rpm-build
    libuuid-devel
    glib2-devel
    xmlto
    asciidoc

Running the build process
-------------------------

Type

    make

Now for storm the binary distribution is downloaded and turned into rpms.
For zeromq the sources are downloaded and built into rpms.

For correctly building jzmq there is an explicit need for the correct zeromq dependencies.
So the build process will stop and ask you to install the zeromq and zeromq-devel rpms that have just been built.
After this has been done you can continue the process again by typing

    make

At the end of this you should have set of files something like this:

    -rw-rw-r--. 1 nbasjes nbasjes    92076 Jul 22 16:07 jzmq-2.1.0-storm_0.8.2.el6.x86_64.rpm
    -rw-rw-r--. 1 nbasjes nbasjes     9523 Jul 22 16:07 jzmq-devel-2.1.0-storm_0.8.2.el6.x86_64.rpm
    -rw-rw-r--. 1 nbasjes nbasjes 14274447 Jul 22 16:02 storm-0.8.2-1.el6.x86_64.rpm
    -rw-rw-r--. 1 nbasjes nbasjes  1236887 Jul 22 15:57 zeromq-2.1.7-storm_0.8.2.el6.x86_64.rpm
    -rw-rw-r--. 1 nbasjes nbasjes   439313 Jul 22 15:57 zeromq-devel-2.1.7-storm_0.8.2.el6.x86_64.rpm

As you can see the rpms that are needed to run this storm have the "Release" value storm_0.8.2.el6 which is the combination of "storm_0.8.2" and the distribution "el6" (which is what you get on CentOS 6.4).

----------

Install Instructions
=====================
In order to run storm you also need to have zookeeper installed and running!

Simply install the 3 non-devel rpms on your nodes

    yum install storm-0.8.2-1.el6.x86_64.rpm jzmq-2.1.0-storm_0.8.2.el6.x86_64.rpm zeromq-2.1.7-storm_0.8.2.el6.x86_64.rpm 

Storm is installed in /opt/storm/ and you can now continue with the regular configuration of storm.

Note that I had to add this line to my config or it wouldn't find the native libjzmq files.

    java.library.path: /usr/lib64/

Because you'll probably want to have storm running continously you can now do

    chkconfig storm-nimbus on
    service storm-nimbus start

    chkconfig storm-ui on
    service storm-ui start

    chkconfig storm-supervisor on
    service storm-supervisor start

