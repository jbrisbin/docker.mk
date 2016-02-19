TAG 				:= dockermk-builder
FROM 				:= ubuntu:trusty
ENTRYPOINT 	:= bash

OVERLAYS		:= docker.mk/overlays/build-essential

include ../docker.mk
