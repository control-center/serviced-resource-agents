# Copyright 2015 The Serviced Authors.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# RPM and DEB and TGZ builder for serviced-resource-agents
#

INSTALL = /usr/bin/install

NAME          ?= serviced-resource-agents
VERSION       ?= $(shell cat ./VERSION)
MAINTAINER     = "Zenoss CM <cm@zenoss.com>"
PKGROOT        = pkgroot
DUID          ?= $(shell id -u)
DGID          ?= $(shell id -g)
DEB_LICENSE    = Apache-2
RPM_LICENSE    = "ASL 2.0"
VENDOR         = "Zenoss, Inc."
URL            = http://controlcenter.io/
DEB_PRIORITY   = extra
CATEGORY       = admin

PKG_VERSION = $(VERSION)
FULL_NAME   = $(NAME)


TEST_CONFIG ?= /etc/default/serviced

define DESCRIPTION
Zenoss Serviced Resource Agents
Allows serviced to run in Linux HA.
endef
export DESCRIPTION

.PHONY: all clean deb rpm test
.SILENT: usage

all: docker-rpm docker-deb

docker-rpm:
	docker build -t zenoss/serviced-resource-agents:rpm-$(PKG_VERSION) ./pkg/rpm
	docker run --rm --user $(DUID):$(DGID) -v `pwd`:/serviced-resource-agents zenoss/serviced-resource-agents:rpm-$(PKG_VERSION)
	./sign-rpm.sh

docker-deb:
	docker build -t zenoss/serviced-resource-agents:deb-$(PKG_VERSION) ./pkg/deb
	docker run --rm --user $(DUID):$(DGID) -v `pwd`:/serviced-resource-agents zenoss/serviced-resource-agents:deb-$(PKG_VERSION)

usage:
	echo "Usage: make deb or make rpm.  Both options package $(FULL_NAME)-$(PKG_VERSION)."

test:
	sudo ocf-tester -n serviced -o config=$(TEST_CONFIG) -o ipaddr=172.17.42.1 -o binary=`which serviced` ocf/serviced

.PHONY: clean_files
clean_files:
	@for pkg in $(FULL_NAME)*.deb $(FULL_NAME)*.rpm ;\
	do \
		if [ -f "$${pkg}" ]; then \
			echo "rm -f $${pkg}" ;\
			if ! rm -f $${pkg} ;then \
				echo "sudo rm -f $${pkg}" ;\
				if ! sudo rm -f $${pkg} ; then \
					echo "Warning: Unable to remove $${pkg}" ;\
					exit 1 ;\
				fi ;\
			fi ;\
		fi ;\
	done

.PHONY: clean_dirs
clean_dirs = $(PKGROOT) build
clean_dirs:
	@for dir in $(clean_dirs) ;\
	do \
		if [ -d "$${dir}" ]; then \
			echo "rm -rf $${dir}" ;\
			if ! rm -rf $${dir} ;then \
				echo "sudo rm -rf $${dir}" ;\
				if ! sudo rm -rf $${dir} ; then \
					echo "Warning: Unable to remove $${dir}" ;\
					exit 1 ;\
				fi ;\
			fi ;\
		fi ;\
	done

# Clean staged files and produced packages
.PHONY: clean
clean: clean_files clean_dirs

# Make root dir for packaging
$(PKGROOT):
	mkdir -p $@

$(PKGROOT)/usr/lib/ocf/resource.d/zenoss: $(PKGROOT)
	mkdir -p $@
	for file in ocf/*; do \
		$(INSTALL) -t $@ -m 0755 $${file} ;\
	done

# Make a DEB
deb: $(PKGROOT)/usr/lib/ocf/resource.d/zenoss
	fpm \
		-n $(FULL_NAME) \
		-v $(PKG_VERSION) \
		-s dir \
		-d serviced \
		-t deb \
		-a x86_64 \
		-C $(PKGROOT) \
		-m $(MAINTAINER) \
		--description "$$DESCRIPTION" \
		--deb-user root \
		--deb-group root \
		--deb-priority $(DEB_PRIORITY) \
		--license $(DEB_LICENSE) \
		--vendor $(VENDOR) \
		--url $(URL) \
		--category $(CATEGORY) \
		.

# Make a RPM
rpm: $(PKGROOT)/usr/lib/ocf/resource.d/zenoss
	fpm \
		-n $(FULL_NAME) \
		-v $(PKG_VERSION) \
		-s dir \
		-d serviced \
		-t rpm \
		-a x86_64 \
		-C $(PKGROOT) \
		-m $(MAINTAINER) \
		--description "$$DESCRIPTION" \
		--rpm-user root \
		--rpm-group root \
		--license $(RPM_LICENSE) \
		--vendor $(VENDOR) \
		--url $(URL) \
		--category $(CATEGORY) \
		.
