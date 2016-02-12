
# Overlays are snippets of Dockerfiles that can be parameterized and overridden
OVERLAYS_DIR  ?= overlays
OVERLAYS      ?=

OVERLAY_FILES := $(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(OVERLAYS))

define source_overlay
$(shell cat $(1) | grep '^#:mk' | sed 's/^#:mk\(.*\)/$$\(eval \1\)/')
endef

define add_overlay
$(eval DOCKER_BUILD_OPTS += --build-arg=CURDIR=$(shell basename $(dir $(realpath $(1)))))
$(overlay_verbose) cat $(1) | grep -v '^#:mk' >>$(DOCKERFILE)
endef
