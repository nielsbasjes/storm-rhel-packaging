#!/bin/bash

#Put the version of storm you need in the next line
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!

#For storm we will simply download the precompiled distribution
STORMVERSION=0.9.0.1
STORMURL=https://dl.dropboxusercontent.com/s/dj86w8ojecgsam7/storm-0.9.0.1.zip
ZEROMQVERSION=2.1.7
ZEROMQVERSIONTAG=v2.1.7

#For jzmq we will do a git clone and then build 
# Note that this must be the same version as is packaged inside the storm we downloaded
JZMQVERSION=2.1.0

RPMRELEASE=storm_$(STORMVERSION)

all: rpm

# =======================================================================
#
.PHONY: storm-rpm
rpm:: storm-rpm
storm-rpm: storm-$(STORMVERSION)*.rpm

storm-$(STORMVERSION)*.rpm: storm-$(STORMVERSION).tgz
	@echo "Building the rpm"
	-@mkdir -p RPM_BUILDING/BUILD  RPM_BUILDING/RPMS  RPM_BUILDING/SOURCES  RPM_BUILDING/SPECS  RPM_BUILDING/SRPMS
	@rpmbuild --define="_topdir `pwd`/RPM_BUILDING" -tb storm-$(STORMVERSION).tgz
	@find RPM_BUILDING/{,S}RPMS/ -type f | xargs -n1 -iXXX mv XXX .
	@echo
	@echo "================================================="
	@echo "The rpms have been created and can be found here:"
	@ls -laF storm*rpm
	@echo "================================================="

storm-$(STORMVERSION).tgz: storm-$(STORMVERSION) storm-$(STORMVERSION)/storm.spec 
	@echo "Creating a modified $@ file."
	#@cp rpm/log4j/storm.log.properties storm-$(STORMVERSION)/log4j/storm.log.properties
	@cp -a rpm storm-$(STORMVERSION)
	@tar czf $@ $<

storm-$(STORMVERSION)/storm.spec: storm-$(STORMVERSION) rpm/storm.spec.in
	@cat rpm/storm.spec.in | \
	    sed "\
	      s/\#\#VERSION\#\#/$(STORMVERSION)/g;\
	      s/\#\#JZMQVERSION\#\#/$(JZMQVERSION)-$(RPMRELEASE)%{?dist}/g;\
	      s/\#\#ZEROMQVERSION\#\#/$(ZEROMQVERSION)-$(RPMRELEASE)%{?dist}/g;\
	    " > storm-$(STORMVERSION)/storm.spec

storm-$(STORMVERSION): storm-$(STORMVERSION).zip
	@echo "Unpacking the original distribution."
	@touch storm-$(STORMVERSION).zip
	@unzip -qq storm-$(STORMVERSION).zip

storm-$(STORMVERSION).zip:
	@echo "Downloading the original distribution."
	@wget $(STORMURL)

clean::
	@echo -n "Cleaning storm "
	@rm -rf storm-$(STORMVERSION) storm-$(STORMVERSION).tgz storm-$(STORMVERSION)*rpm RPM_BUILDING
	@echo "done."

# =======================================================================

.PHONY: zeromq-rpm
rpm:: zeromq-rpm
zeromq-rpm: zeromq-$(ZEROMQVERSION)*.rpm

zeromq-$(ZEROMQVERSION)*.rpm: zeromq/zeromq-$(ZEROMQVERSION).tar.gz
	@echo "Building the rpm"
	-@mkdir -p RPM_BUILDING/BUILD  RPM_BUILDING/RPMS  RPM_BUILDING/SOURCES  RPM_BUILDING/SPECS  RPM_BUILDING/SRPMS
	@rpmbuild --define="_topdir `pwd`/RPM_BUILDING" -tb $<
	@find RPM_BUILDING/{,S}RPMS/ -type f | xargs -n1 -iXXX mv XXX .
	@echo
	@echo "================================================="
	@echo "The rpms have been created and can be found here:"
	@ls -laF zeromq*rpm
	@echo "================================================="

zeromq/zeromq-$(ZEROMQVERSION).tar.gz: zeromq/builds/redhat/zeromq.spec.in
	@echo "Creating a $@ file."
	@(\
	  cd zeromq; \
	  ./autogen.sh ; \
	  ./configure ; \
	  make dist -j6 ;\
	 )

zeromq/builds/redhat/zeromq.spec.in:
	@echo "Get storm stable version of zeromq."
	@git clone https://github.com/zeromq/zeromq2-x zeromq
	@( cd zeromq; git checkout $(ZEROMQVERSIONTAG) )
	@sed -i 's/\(Release: *\)1\(.*\)/\1$(RPMRELEASE)\2/g' $@

zeromq-devel-$(ZEROMQVERSION).installed:
	@(\
	  rpm -q zeromq-devel | fgrep zeromq-devel-$(ZEROMQVERSION); \
	  STATUS=$$? ; \
	  if [[ $${STATUS} == 0 ]]; \
	  then \
	    echo INSTALLED > $@ ; \
	  else \
	    echo "Now install zeromq-devel-$(ZEROMQVERSION) (this has just been built) and type \"make\" again (killing the build now)." ; \
	    exit 1; \
	  fi \
	)

clean::
	@echo -n "Cleaning zeromq "
	@rm -rf zeromq zeromq-$(ZEROMQVERSION).tar.gz zeromq-$(ZEROMQVERSION)*rpm zeromq-devel-$(ZEROMQVERSION)*rpm RPM_BUILDING zeromq-devel-$(ZEROMQVERSION).installed
	@echo "done."

# =======================================================================
.PHONY: jzmq-rpm
rpm:: jzmq-rpm
jzmq-rpm: jzmq-$(JZMQVERSION)*.rpm

jzmq-$(JZMQVERSION)*.rpm: jzmq-$(JZMQVERSION).tar.gz zeromq-devel-$(ZEROMQVERSION).installed
	@echo "Building the rpm"
	-@mkdir -p RPM_BUILDING/BUILD  RPM_BUILDING/RPMS  RPM_BUILDING/SOURCES  RPM_BUILDING/SPECS  RPM_BUILDING/SRPMS
	@rpmbuild --define="_topdir `pwd`/RPM_BUILDING" -tb $<
	@find RPM_BUILDING/{,S}RPMS/ -type f | xargs -n1 -iXXX mv XXX .
	@echo
	@echo "================================================="
	@echo "The rpms have been created and can be found here:"
	@ls -laF jzmq*rpm
	@echo "================================================="


jzmq-$(JZMQVERSION).tar.gz: jzmq-$(JZMQVERSION) jzmq-$(JZMQVERSION)/jzmq.spec
	@echo "Creating a $@ file."
	@tar czf $@ $<

jzmq-$(JZMQVERSION)/jzmq.spec: jzmq-$(JZMQVERSION)
	@echo "Get spec file fixes from the 2.2.0 version."
	@curl https://raw.github.com/zeromq/jzmq/v2.2.0/jzmq.spec | \
	      sed 's/2\.2\.0/$(JZMQVERSION)/g' | \
	      sed 's/\(Release: *\)1\(.*\)/\1$(RPMRELEASE)\2/g' | \
	      sed 's/\(Requires:.*\)zeromq\(.*\)/\1zeromq = $(ZEROMQVERSION)-$(RPMRELEASE)%{?dist}\2/g'  \
	      > jzmq-$(JZMQVERSION)/jzmq.spec

jzmq-$(JZMQVERSION):
	@echo "Get storm stable version of jzmq."
	@git clone https://github.com/nathanmarz/jzmq.git jzmq-$(JZMQVERSION)
	@rm -f jzmq-$(JZMQVERSION)/jzmq.spec

clean::
	@echo -n "Cleaning jzmq "
	@rm -rf jzmq-$(JZMQVERSION) jzmq-$(JZMQVERSION).tar.gz jzmq-$(JZMQVERSION)*rpm jzmq-devel-$(JZMQVERSION)*rpm RPM_BUILDING
	@echo "done."

# =======================================================================
