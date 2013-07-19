#!/bin/bash

#Put the version of storm you need in the next line
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!

#For storm we will simply download the precompiled distribution
STORMVERSION=0.8.2

#For jzmq we will do a git clone and then build the defined git tag
JZMQVERSION=2.2.0
JZMQVERSIONTAG=v2.2.0

all: rpm

# =======================================================================
#
rpm:: storm-$(STORMVERSION)*.rpm

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
	@cp rpm/log4j/storm.log.properties storm-$(STORMVERSION)/log4j/storm.log.properties
	@cp -a rpm storm-$(STORMVERSION)
	@tar czf $@ $<

storm-$(STORMVERSION)/storm.spec: storm-$(STORMVERSION) rpm/storm.spec.in
	@sed "s/\#\#VERSION\#\#/$(STORMVERSION)/g" < rpm/storm.spec.in > storm-$(STORMVERSION)/storm.spec

storm-$(STORMVERSION): storm-$(STORMVERSION).zip
	@echo "Unpacking the original distribution."
	@unzip -qq storm-$(STORMVERSION).zip

storm-$(STORMVERSION).zip:
	@echo "Downloading the original distribution."
	@wget https://dl.dropbox.com/u/133901206/storm-$(STORMVERSION).zip

clean::
	@echo -n "Cleaning storm "
	@rm -rf storm-$(STORMVERSION) storm-$(STORMVERSION).tgz storm-$(STORMVERSION)*rpm RPM_BUILDING
	@echo "done."

# =======================================================================

rpm:: jzmq-$(JZMQVERSION)*.rpm

jzmq-$(JZMQVERSION)*.rpm: jzmq-$(JZMQVERSION).tar.gz
	@echo "Building the rpm"
	-@mkdir -p RPM_BUILDING/BUILD  RPM_BUILDING/RPMS  RPM_BUILDING/SOURCES  RPM_BUILDING/SPECS  RPM_BUILDING/SRPMS
	@rpmbuild --define="_topdir `pwd`/RPM_BUILDING" -tb jzmq-$(JZMQVERSION).tar.gz
	@find RPM_BUILDING/{,S}RPMS/ -type f | xargs -n1 -iXXX mv XXX .
	@echo
	@echo "================================================="
	@echo "The rpms have been created and can be found here:"
	@ls -laF jzmq*rpm
	@echo "================================================="

jzmq-$(JZMQVERSION).tar.gz: jzmq-$(JZMQVERSION)
	@echo "Creating a $@ file."	
	@tar czf $@ $<

jzmq-$(JZMQVERSION):
	@git clone https://github.com/zeromq/jzmq.git jzmq-$(JZMQVERSION)
	@( cd jzmq-$(JZMQVERSION) ; git checkout $(JZMQVERSIONTAG) )


clean::
	@echo -n "Cleaning jzmq "
	@rm -rf jzmq-$(JZMQVERSION) jzmq-$(JZMQVERSION).tar.gz jzmq-$(JZMQVERSION)*rpm jzmq-devel-$(JZMQVERSION)*rpm RPM_BUILDING
	@echo "done."

# =======================================================================
