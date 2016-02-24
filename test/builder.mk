TAG 				:= dockermk-builder
FROM 				:= ubuntu:trusty
ENTRYPOINT 	:= bash

OVERLAYS		:= docker.mk/ubuntu/build-essential

include ../docker.mk
