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
overlay_verbose_0 = @echo " OVERLAY " $(OVERLAY_FILES);
overlay_verbose_2 = set -x;
overlay_verbose = $(overlay_verbose_$(V))

# Core targets for docker.mk
TAG 				?=
FROM 				?= ubuntu
MAINTAINER 	?=
ENTRYPOINT 	?=

DOCKERFILE 	?= Dockerfile

.PHONY = clean install

clean:
	$(verbose) rm -f $(DOCKERFILE)

install: $(DOCKERFILE)
	$(build_verbose) docker build -t $(TAG) $(CURDIR)

$(DOCKERFILE):
	$(build_verbose) echo FROM $(FROM) >$(DOCKERFILE)
ifneq (,$(strip $(MAINTAINER)))
	$(verbose) echo MAINTAINER "$(MAINTAINER)" >>$(DOCKERFILE)
endif
	$(call overlays)
ifneq (,$(strip $(ENTRYPOINT)))
	$(verbose) echo ENTRYPOINT $(ENTRYPOINT) >>$(DOCKERFILE)
endif

# Overlays are snippets of Dockerfiles that can be parameterized and overridden
OVERLAYS_DIR  ?= overlays
OVERLAYS      ?=

OVERLAY_FILES := $(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(OVERLAYS))

define overlays
$(overlay_verbose) echo $(foreach overlay,$(OVERLAY_FILES),\
	$(shell sed "s#\$CURDIR/#$(dir $(realpath $(overlay)))#" $(overlay) | sed "s#$(CURDIR)##")) >>$(DOCKERFILE)
endef
