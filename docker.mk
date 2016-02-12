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

# Core targets for docker.mk
TAG 				?=
LABEL				?=
FROM 				?= ubuntu
MAINTAINER 	?=
ENTRYPOINT 	?=

DOCKERFILE 	?= Dockerfile

DOCKER_BUILD_OPTS 	?=
DOCKER_TEST_OPTS 		?=
DOCKER_PUSH_OPTS 		?=

.PHONY = all clean install push test

all: $(DOCKERFILE)

clean:
	rm -f $(DOCKERFILE)

install: $(DOCKERFILE)
	docker build -t $(TAG) $(DOCKER_BUILD_OPTS) $(CURDIR)

push:
	docker push $(DOCKER_PUSH_OPTS) $(TAG)

test: install
	docker run -e TEST=true $(DOCKER_TEST_OPTS) $(TAG)

$(DOCKERFILE):
	$(foreach overlay,$(OVERLAY_FILES), $(eval $(call source_overlay,$(overlay))))
	$(build_verbose) echo FROM $(FROM) >$(DOCKERFILE)
ifneq (,$(strip $(MAINTAINER)))
	$(verbose) echo MAINTAINER "$(MAINTAINER)" >>$(DOCKERFILE)
endif
ifneq (,$(strip $(LABEL)))
	$(verbose) echo LABEL $(LABEL) >>$(DOCKERFILE)
endif
	$(foreach overlay,$(OVERLAY_FILES), $(call add_overlay,$(overlay)))
ifneq (,$(strip $(ENTRYPOINT)))
	$(verbose) echo ENTRYPOINT $(ENTRYPOINT) >>$(DOCKERFILE)
endif

# Overlays are snippets of Dockerfiles that can be parameterized and overridden
OVERLAYS_DIR  ?= overlays
OVERLAYS      ?=

OVERLAY_FILES := $(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(OVERLAYS))

define source_overlay
$(shell cat $(1) | grep '^#:mk' | sed 's/^#:mk\(.*\)/$$\(eval \1\)/')
endef

define add_overlay
$(overlay_verbose) cat $(1) | grep -v '^#:mk' | sed 's#$$CURDIR#$(shell basename $(dir $(realpath $(1))))#' >>$(DOCKERFILE)
endef
