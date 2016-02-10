DOCKER_MK_VERSION := 1

DOCKER_MK := docker.mk

MODULES_CONFIG := $(shell sed "s/\#.*//" $(CURDIR)/modules.config)

.PHONY := all clean

all:
	@ cat $(patsubst %,src/%.mk,$(MODULES_CONFIG)) \
		| sed 's/^DOCKER_MK_VERSION = .*/DOCKER_MK_VERSION = $(DOCKER_MK_VERSION)/' >$(DOCKER_MK)

clean:
	@ $(MAKE) -C test clean

test: all
	@ $(MAKE) -C test test
