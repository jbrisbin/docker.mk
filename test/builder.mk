TAG 				:= dockermk-builder
FROM 				:= ubuntu:trusty
ENTRYPOINT 	:= bash

OVERLAYS_DIR := ../overlays
OVERLAYS		:= build-essential

include ../docker.mk
