TAG 				?=
FROM 				?= ubuntu
MAINTAINER 	?=
ENTRYPOINT 	?=

DOCKERFILE 	?= Dockerfile

.PHONY = clean install

clean:
	$(verbose) rm -f $(DOCKERFILE)

install: $(DOCKERFILE)
	$(build_verbose) docker build -t $(TAG) $(CURDIR)

$(DOCKERFILE):
	$(build_verbose) echo FROM $(FROM) >$(DOCKERFILE)
ifneq (,$(strip $(MAINTAINER)))
	$(verbose) echo MAINTAINER "$(MAINTAINER)" >>$(DOCKERFILE)
endif
	$(call overlays)
ifneq (,$(strip $(ENTRYPOINT)))
	$(verbose) echo ENTRYPOINT $(ENTRYPOINT) >>$(DOCKERFILE)
endif
