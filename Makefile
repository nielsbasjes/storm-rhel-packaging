#!/bin/bash

#Put the version of storm you need in the next line
#BEWARE THAT THIS MAY NOT CONTAIN A '-' !!!

#For storm we will simply download the precompiled distribution
STORMVERSION=0.9.2_zk345

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

storm-$(STORMVERSION): storm-sources/storm-dist/binary/target/apache-storm-$(STORMVERSION).tar.gz
	tar xzf storm-sources/storm-dist/binary/target/apache-storm-$(STORMVERSION).tar.gz
	rm -rf storm-$(STORMVERSION)
	mv apache-storm-$(STORMVERSION) storm-$(STORMVERSION)

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

storm-sources/storm-dist/binary/target/apache-storm-$(STORMVERSION).tar.gz: storm-sources/.gitignore
	( \
	cd storm-sources ; \
	mvn install -DskipTests=true ; \
	cd storm-dist/binary/ ; \
	mvn package -DskipTests=true -Pdist -Dgpg.skip=true ;\
	) 

storm-sources/.gitignore:
	@echo "Downloading sources."
	( \
	git clone git://git.apache.org/incubator-storm.git storm-sources; \
	cd storm-sources  ; \
	git remote add STORM70 https://github.com/revans2/incubator-storm.git; \
	git fetch STORM70 ; \
	git merge STORM70/storm-70-zk-upgrade -m"Merge STORM-70"; \
	find . -type f -name pom.xml | xargs -n1 -r -iXXX sed -i "s@<version>0.9.2-incubating-SNAPSHOT</version>@<version>$(STORMVERSION)</version>@g" XXX; \
	)
	touch $@

clean::
	@echo -n "Cleaning storm "
	@rm -rf storm-sources storm-$(STORMVERSION).tgz storm-$(STORMVERSION) storm-$(STORMVERSION)*rpm RPM_BUILDING
	@echo "done."

