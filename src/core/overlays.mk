
# Overlays are snippets of Dockerfiles that can be parameterized and overridden
OVERLAYS_DIR  ?= overlays
OVERLAYS      ?=

OVERLAY_FILES := $(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(OVERLAYS))

define overlays
$(overlay_verbose) echo $(foreach overlay,$(OVERLAY_FILES),\
	$(shell sed "s#\$CURDIR/#$(dir $(realpath $(overlay)))#" $(overlay) | sed "s#$(CURDIR)##")) >>$(DOCKERFILE)
endef
