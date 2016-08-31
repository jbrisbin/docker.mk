WORKDIR 							= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
DOCKERMK 						 ?= $(WORKDIR)dockermk

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
OVERLAY_DIRS 				 ?= . overlays
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
TESTS 							 ?= $(shell ls test/*.mk 2>/dev/null)

.PHONY = all install distclean clean testclean test

install:: $(DOCKERFILE)
	docker build -t $(TAG) -f $(DOCKERFILE) $(DOCKER_BUILD_OPTS) .

distclean:: clean
	@CONTAINERS=`docker ps -aqf ancestor=$(TAG) | tr '\n' ' '`; \
	if [ -n "$$CONTAINERS" ]; then \
		echo "CLEAN $$CONTAINERS"; \
		docker rm -f $$CONTAINERS >/dev/null; \
	fi
	docker rmi $(TAG)

clean::
	rm -f $(DOCKERFILE)

testclean::
	@for t in "$(TESTS)"; do \
		$(MAKE) -C test -f `basename $$t` distclean; \
	done

test::
	@for t in "$(TESTS)"; do \
		TEST_TARGETS=`egrep -o 'test-.*:' $$t | tr '\n' ' ' | tr -d :`; \
		echo "TEST $$t: $$TEST_TARGETS"; \
		$(MAKE) -C test -f `basename $$t` $$TEST_TARGETS; \
	done

$(DOCKERFILE):: $(DOCKERMK) $(OVERLAY_FILES)
	$(DOCKERMK) \
	-w $(realpath .) \
	-f $(DOCKERFILE) \
	-d $(shell echo $(OVERLAY_DIRS) | tr ' ' :) \
	-from $(FROM) \
	$(DOCKERMK_OPTS) \
	$(OVERLAYS)

$(DOCKERMK):
	@echo "Downloading dockermk utility from GitHub..."
	curl -sL -o $(DOCKERMK) https://github.com/jbrisbin/docker.mk/releases/download/0.4.0/dockermk-`uname -s`
	@chmod a+x $(DOCKERMK)
