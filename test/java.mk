TAG 				:= dockermk-java
FROM 				:= ubuntu:trusty

SHARED_OVERLAYS := java8

include ../docker.mk
