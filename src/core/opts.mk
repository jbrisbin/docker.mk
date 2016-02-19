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
