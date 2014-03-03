#!/bin/bash

#Put the version of storm you need in the next line
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!

#For storm we will simply download the precompiled distribution
STORMVERSION=0.9.2_zk345
STORMDIRBASENAME=apache-storm-0.9.2-zk345
STORMURL=http://apache.mirror.1000mbps.com/incubator/storm/$(STORMDIRBASENAME)/$(STORMDIRBASENAME).tar.gz

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
	@cp -a rpm storm-$(STORMVERSION)
	@tar czf $@ $<

storm-$(STORMVERSION)/storm.spec: storm-$(STORMVERSION) rpm/storm.spec.in RELEASE rpm/* rpm/*/* Makefile
	@read REL < RELEASE ; (( REL += 1)) ; echo $${REL} > RELEASE 
	@cat rpm/storm.spec.in | \
	    sed "\
	      s@\#\#VERSION\#\#@$(STORMVERSION)@g;\
	      s@\#\#RELEASE\#\#@$$(cat RELEASE)@g;\
	      s@\#\#SOURCE\#\#@storm-$(STORMVERSION).tgz@g;\
	    " > $@

RELEASE:
	@echo 0 > $@

storm-$(STORMVERSION): $(STORMDIRBASENAME).tar.gz
	@echo "Unpacking the original distribution."
	@touch $<
	@tar xzf $<
	@mv $(STORMDIRBASENAME) storm-$(STORMVERSION)

$(STORMDIRBASENAME).tar.gz:
	@echo "Downloading the original distribution."
	@curl $(STORMURL) > $@

clean::
	@echo -n "Cleaning storm "
	@rm -rf $(STORMDIRBASENAME) storm-$(STORMVERSION).tgz storm-$(STORMVERSION) storm-$(STORMVERSION)*rpm RPM_BUILDING
	@echo "done."

