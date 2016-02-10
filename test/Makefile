TAG 				:= dockermk
FROM 				:= ubuntu:trusty
MAINTAINER 	:= John Doe <john.doe@gmail.com>
ENTRYPOINT 	:= /test.sh
OVERLAYS		:= simple

include ../docker.mk

test: install
	@docker run $(TAG)
