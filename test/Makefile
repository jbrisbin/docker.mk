TAG 				:= dockermk
FROM 				:= ubuntu:trusty
MAINTAINER 	:= John Doe <john.doe@gmail.com>
ENTRYPOINT 	:= /test.sh
#ENTRYPOINT 	:= bash
OVERLAYS		:= simple ephemeral

include ../docker.mk

$(OVERLAYS_DIR)/ephemeral.Dockerfile:
	curl https://gist.githubusercontent.com/jbrisbin/bc5c5a91d2e3952d7743/raw/36a457fd701ab41cfddeb5f2c4845b646021b32b/ephemeral.Dockerfile >$(@)

clean::
	rm -f $(OVERLAYS_DIR)/ephemeral.Dockerfile
