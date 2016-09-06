WORKDIR 							= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
DOCKERMK 						 ?= $(WORKDIR)dockermk
DOCKERMK_VERS         = 0.4.0
DOCKERMK_VERS_CURRENT = $(awk 'BEGIN{FS="="}/DOCKERMK_VERS/{print $2}' $(WORKDIR)/.dockermk)

# OS discovery
OS                   ?= alpine-3.4
OS_FAMILY             = $(shell echo $(OS) | cut -d- -f1)
OS_VERSION            = $(shell echo $(OS) | cut -d- -f2)
ubuntu_14.04_name     = trusty
debian_8_name         = jessie
centos_7_name         = x64
alpine_3.4_name       = x64
OS_FLAVOR             = $($(OS_FAMILY)_$(OS_VERSION)_name)
export OS OS_FAMILY OS_VERSION OS_FLAVOR

# Core options for docker.mk
TAG                  ?= $(shell basename $(WORKDIR))
FROM                 ?= alpine
MAINTAINER           ?=
ENTRYPOINT           ?=
CMD				           ?=

# Options to influence Docker
DOCKERFILE           ?= Dockerfile
DOCKER_BUILD_OPTS    ?=
DOCKER_RUN_OPTS      ?= --rm -it
DOCKER_PUSH_OPTS     ?=
DOCKER_TEST_OPTS     ?=

# Default overlay search dirs
OVERLAY_DIRS 				 ?= $(OS_FAMILY)/$(OS_VERSION) $(OS_FAMILY) common overlays .
OVERLAYS             ?=
OVERLAY_FILES 				= $(shell [ -x $(DOCKERMK) ] && $(DOCKERMK) -o -w $(realpath .) -d $(shell echo $(OVERLAY_DIRS) | tr ' ' :) $(OVERLAYS))

# Options to add standard lines to the Dockerfile
DOCKERMK_OPTS 			 ?=
ifdef MAINTAINER
DOCKERMK_OPTS 			 += -maintainer '$(MAINTAINER)'
endif
ifdef ENTRYPOINT
DOCKERMK_OPTS 			 += -entrypoint '$(ENTRYPOINT)'
endif
ifdef CMD
DOCKERMK_OPTS 			 += -cmd '$(CMD)'
endif

# Test harness
TESTS 							 ?= $(shell [ -d test ] && ls test/*.mk)

.PHONY: install distclean clean testclean test

install:: $(DOCKERFILE)
	docker build -t $(TAG) -f $(DOCKERFILE) $(DOCKER_BUILD_OPTS) .

distclean:: clean
	@CONTAINERS=`docker ps -aqf ancestor=$(TAG) | tr '\n' ' '`; \
	if [ -n "$$CONTAINERS" ]; then \
		echo "CLEAN $$CONTAINERS"; \
		docker rm -f $$CONTAINERS >/dev/null; \
	fi
	if [ -n "$(shell docker images -q -a $(TAG))" ]; then docker rmi $(TAG); fi

clean::
	rm -f $(DOCKERFILE)

testclean::
	@for t in $(TESTS); do \
		TEST_NAME=`basename $$t`; \
		CONTAINERS="$(shell docker ps -aqf ancestor=$(TAG))"; \
		export DOCKERFILE=$${TEST_NAME%.mk}-Dockerfile; \
		$(MAKE) -C test -f $$TEST_NAME distclean; \
	done

test:: $(DOCKERFILE)
	@for t in $(TESTS); do \
		TEST_TARGETS=`egrep -o 'test-.*:' $$t | tr '\n' ' ' | tr -d :`; \
		echo "TEST $$t: $$TEST_TARGETS"; \
		TEST_NAME=`basename $$t`; \
		export DOCKERFILE=$${TEST_NAME%.mk}-Dockerfile; \
		$(MAKE) -C test -f $$TEST_NAME $$TEST_TARGETS; \
	done

$(DOCKERFILE):: $(DOCKERMK) $(OVERLAY_FILES)
	$(DOCKERMK) \
	-w $(realpath .) \
	-f $(DOCKERFILE) \
	-d $(shell echo $(OVERLAY_DIRS) | tr ' ' :) \
	-from $(FROM) \
	$(DOCKERMK_OPTS) \
	$(OVERLAYS)

$(DOCKERMK): $(WORKDIR)/.dockermk
ifneq (x$(DOCKERMK_VERS_CURRENT),x$(DOCKERMK_VERS))
	@echo "Downloading dockermk-`uname -s` utility from GitHub..."
	curl -sL -o $(DOCKERMK) https://github.com/jbrisbin/docker.mk/releases/download/$(DOCKERMK_VERS)/dockermk-`uname -s`
	@chmod a+x $(DOCKERMK)
	echo "DOCKERMK_VERS=$(DOCKERMK_VERS)" >$(WORKDIR)/.dockermk;
endif

$(WORKDIR)/.dockermk:
	touch $(WORKDIR)/.dockermk
