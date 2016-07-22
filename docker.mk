DOCKERMK 						 ?= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))dockermk

# Core options for docker.mk
TAG                  ?= $(notdir $(realpath $(lastword $(MAKEFILE_LIST))))
FROM                 ?= alpine
MAINTAINER           ?=
ENTRYPOINT           ?=
CMD				           ?=

DOCKERFILE           ?= Dockerfile
DOCKER_BUILD_OPTS    ?=
DOCKER_RUN_OPTS      ?= --rm -it
DOCKER_PUSH_OPTS     ?=
DOCKER_TEST_OPTS     ?=

OVERLAY_DIRS 				 ?= . overlays
OVERLAYS             ?=

DOCKERMK_OPTS 			 ?=
ifneq ($(MAINTAINER),)
DOCKERMK_OPTS += -maintainer $(MAINTAINER)
endif
ifneq ($(ENTRYPOINT),)
DOCKERMK_OPTS += -entrypoint $(ENTRYPOINT)
endif
ifneq ($(CMD),)
DOCKERMK_OPTS += -cmd $(CMD)
endif

.PHONY = all install clean test $(DOCKERFILE)

all:: install

install:: $(DOCKERFILE)
	docker build -t $(TAG) -f $(DOCKERFILE) $(DOCKER_BUILD_OPTS) .

clean::
	rm -f $(DOCKERFILE)

$(DOCKERFILE):: $(DOCKERMK)
	$(DOCKERMK) \
	-w $(realpath .) \
	-f $(DOCKERFILE) \
	-d $(shell echo $(OVERLAY_DIRS) | tr ' ' :) \
	-from $(FROM) \
	$(DOCKERMK_OPTS) \
	$(OVERLAYS)

$(DOCKERMK):
	@curl -sL -o $(DOCKERMK) https://raw.githubusercontent.com/jbrisbin/docker.mk/master/dockermk
	@chmod a+x $(DOCKERMK)
