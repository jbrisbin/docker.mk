# Overlays are snippets of Dockerfiles that can be parameterized and overridden

$(OVERLAYS_DIR)/docker.mk::
	git clone https://github.com/jbrisbin/docker.mk.git $(OVERLAYS_DIR)/docker.mk

$(patsubst %,$(OVERLAYS_DIR)/docker.mk/%.Dockerfile,$(BUILTIN_OVERLAYS)): $(OVERLAYS_DIR)/docker.mk
	$(verbose) echo "Downloaded built-in overlays"

$(patsubst %,$(OVERLAYS_DIR)/%.Dockerfile,$(SHARED_OVERLAYS))::
	rm -f $(@) && ln -s $(SHARED_OVERLAYS_DIR)/$(@) $(@)

define source_overlay
awk '/^#:mk[ ]/ {print "$$(eval " substr($$0, 6) ")"}' $(1);
endef

define add_overlay
awk '!/^#:mk[ ]/ {print $$0}' $(1) | sed "s#\$$CURDIR/#$(dir $(realpath $(1)))#" | sed "s#$(CURDIR)/##" >>$(DOCKERFILE);
endef

clean::
	$(foreach shovr,$(SHARED_OVERLAYS), rm -f $(OVERLAYS_DIR)/$(shovr).Dockerfile;)
