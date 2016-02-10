
# Overlays are snippets of Dockerfiles that can be parameterized and overridden
OVERLAYS_DIR  ?= overlays
OVERLAYS      ?=

OVERLAY_FILES := $(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(OVERLAYS))

define add_overlay
	$(exec OVERLAY_DIR := $(dir $(realpath $(1))))
	$(verbose) cat $(1) | sed "s|\$CURDIR/|$(OVERLAY_DIR)|" | sed "s|$(CURDIR)||" >>$(DOCKERFILE)
endef
