TAG = dockermk
MAINTAINER = "Jon Brisbin <jon@jbrisbin.com>"
CMD = bash
OVERLAYS = utils first second third

include ../docker.mk

OVERLAY_DIRS += ubuntu

all:: test
	
test:: clean install
	docker run --rm -i dockermk cat /etc/config
