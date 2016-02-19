BUILTIN_OVERLAYS := overlays/build-essential overlays/java8 overlays/sbt
# Global verbosity settings
V ?= 0

verbose_0 = @
verbose_2 = set -x;
verbose = $(verbose_$(V))

# BUILD verbosity settings
build_verbose_0 = @echo " BUILD   " $(TAG);
build_verbose_2 = set -x;
build_verbose = $(build_verbose_$(V))

# OVERLAY verbosity settings
overlay_verbose_0 = @echo " OVERLAY " $(OVERLAYS);
overlay_verbose_2 = set -x;
overlay_verbose = $(overlay_verbose_$(V))
# Core options for docker.mk
TAG                  ?= $(notdir $(realpath $(lastword $(MAKEFILE_LIST))))
LABEL                ?=
FROM                 ?= ubuntu
MAINTAINER           ?=
ENTRYPOINT           ?=

DOCKERFILE           ?= Dockerfile
DOCKER_BUILD_OPTS    ?=
DOCKER_PUSH_OPTS     ?=
DOCKER_TEST_OPTS     ?=

OVERLAYS_DIR         ?= overlays
SHARED_OVERLAYS_DIR  ?= ..
OVERLAYS             ?=
SHARED_OVERLAYS      ?=
IGNORE_OVERLAYS      ?=

OVERLAY_FILES        := $(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(filter-out $(IGNORE_OVERLAYS),$(OVERLAYS))) \
	$(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(filter-out $(IGNORE_OVERLAYS),$(SHARED_OVERLAYS)))

IGNORE_TESTS         ?=
TEST_DIR             ?= test
TEST_TARGET          ?= test
TEST_CLEAN_TARGET    ?= test-clean

TEST_FILES           := $(filter-out $(IGNORE_TESTS),$(wildcard $(TEST_DIR)/*.mk))
# Overlays are snippets of Dockerfiles that can be parameterized and overridden

$(OVERLAYS_DIR)/docker.mk::
	git clone https://github.com/jbrisbin/docker.mk.git $(OVERLAYS_DIR)/docker.mk

$(patsubst %,$(OVERLAYS_DIR)/docker.mk/%.Dockerfile,$(BUILTIN_OVERLAYS)): $(OVERLAYS_DIR)/docker.mk
	$(verbose) echo "Downloaded built-in overlays"

$(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(SHARED_OVERLAYS))::
	ln -f $(SHARED_OVERLAYS_DIR)/$(@) $(@)

define source_overlay
$(shell [ -f "$(1)" ] && cat $(1) | grep '^#:mk' | sed 's/^#:mk\(.*\)/$$\(eval \1\)/')
endef

define add_overlay
grep -v '^#:mk' $(1) | sed "s#\$$CURDIR/#$(dir $(realpath $(1)))#" | sed "s#$(CURDIR)/##" >>$(DOCKERFILE);
endef

clean::
	$(foreach shovr,$(SHARED_OVERLAYS), rm -f $(OVERLAYS_DIR)/$(shovr).Dockerfile;)

.PHONY = all clean install push test

all: install

clean::
	rm -f $(DOCKERFILE)
	rm -Rf $(OVERLAYS_DIR)/docker.mk

install:: $(DOCKERFILE)
	docker build -t $(TAG) $(DOCKER_BUILD_OPTS) $(CURDIR)

push::
	docker push $(DOCKER_PUSH_OPTS) $(TAG)

test:: install
	docker run -e TEST=true $(DOCKER_TEST_OPTS) $(TAG)

$(OVERLAYS_DIR):
	$(verbose)

$(DOCKERFILE): $(OVERLAYS_DIR) $(OVERLAY_FILES)
	$(foreach overlay,$(OVERLAY_FILES), $(eval $(call source_overlay,$(overlay))))
	$(build_verbose) echo FROM $(FROM) >$(DOCKERFILE)
ifneq (,$(strip $(MAINTAINER)))
	$(verbose) echo MAINTAINER "$(MAINTAINER)" >>$(DOCKERFILE)
endif
ifneq (,$(strip $(LABEL)))
	$(verbose) echo LABEL $(LABEL) >>$(DOCKERFILE)
endif
	$(overlay_verbose) $(foreach overlay,$(OVERLAY_FILES), $(call add_overlay,$(overlay)))
ifneq (,$(strip $(ENTRYPOINT)))
	$(verbose) echo ENTRYPOINT $(ENTRYPOINT) >>$(DOCKERFILE)
endif
# If a test dir exists, assume we want to run tests
ifeq ($(wildcard test),)
test::
	$(verbose) :
test-clean::
	$(verbose) :
else
test::
	# Filter out ignored tests and run the TEST_TARGET
	$(foreach testmk,$(TEST_FILES), $(MAKE) -C $(TEST_DIR) -f $(shell basename $(testmk)) $(TEST_TARGET))

test-clean::
	echo test-clean
	# Clean up the container we created for the tests
	$(foreach container,$(shell docker ps -a | grep $(TAG) | awk '{print $1}'), $(shell docker rm -f $(container)))
endif
