
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
