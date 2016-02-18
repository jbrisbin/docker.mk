DOCKER_MK_VERSION := 1

DOCKER_MK := docker.mk

MODULES_CONFIG := $(shell sed "s/\#.*//" $(CURDIR)/modules.config)

.PHONY := all clean

all:
	@ cat $(patsubst %,src/%.mk,$(MODULES_CONFIG)) \
		| sed 's/^DOCKER_MK_VERSION = .*/DOCKER_MK_VERSION = $(DOCKER_MK_VERSION)/' >$(DOCKER_MK)

clean:
	$(call foreach-test,clean)

test: all
	$(call foreach-test,test)

define foreach-test
$(foreach testmk,$(wildcard test/*.mk), $(MAKE) -C test -f $(notdir $(testmk)) $(1);)
endef
