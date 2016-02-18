
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

$(DOCKERFILE): $(OVERLAY_FILES)
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
