#!/bin/bash

#Put the version of storm you need in the next line
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!

#TODO: Extract this from the pom.xml in the sources
STORMSOURCEVERSION=0.9.3-SNAPSHOT

STORMVERSION=$(shell echo $(STORMSOURCEVERSION) | sed 's/-/_/g')

## Too slow: GITREPO=git://git.apache.org/storm.git
GITREPO=git://github.com/apache/storm.git

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
	@ls -laF $@
	@echo "================================================="

storm-$(STORMVERSION).tgz: storm-$(STORMVERSION) storm-$(STORMVERSION)/storm.spec 
	@echo "Creating a modified $@ file."
	@cp -a rpm storm-$(STORMVERSION)
	@tar czf $@ $<

storm-$(STORMVERSION): storm-sources/storm-dist/binary/target/apache-storm-$(STORMSOURCEVERSION).tar.gz
	tar xzf $<
	rm -rf $@
	mv apache-storm-$(STORMSOURCEVERSION) $@

storm-$(STORMVERSION)/storm.spec: storm-$(STORMVERSION)/RELEASE rpm/storm.spec.in RELEASE rpm/* rpm/*/* Makefile
	@read REL < RELEASE ; (( REL += 1)) ; echo $${REL} > RELEASE 
	@cat rpm/storm.spec.in | \
	    sed "\
	      s@\#\#VERSION\#\#@$(STORMVERSION)@g;\
	      s@\#\#RELEASE\#\#@$$(cat RELEASE)@g;\
	      s@\#\#SOURCE\#\#@storm-$(STORMVERSION).tgz@g;\
	    " > $@

RELEASE:
	@echo 0 > $@

storm-sources/storm-dist/binary/target/apache-storm-$(STORMSOURCEVERSION).tar.gz: storm-sources/.gitignore
	( \
	cd storm-sources ; \
	sed -i 's@.{storm.home}/logs/@/var/log/storm/@g' logback/cluster.xml ; \
	sed -i 's@storm.local.dir: "storm-local"@storm.local.dir: "/var/opt/storm"@g' conf/defaults.yaml ; \
	mvn install -DskipTests=true ; \
	cd storm-dist/binary/ ; \
	mvn package -DskipTests=true -Pdist -Dgpg.skip=true ;\
	) 

storm-sources/.gitignore:
	@echo "Downloading sources."
	git clone $(GITREPO) storm-sources
	touch $@

clean::
	@echo -n "Cleaning storm "
	@rm -rf storm-sources storm-$(STORMVERSION).tgz storm-$(STORMVERSION) storm-$(STORMVERSION)*rpm RPM_BUILDING
	@echo "done."

