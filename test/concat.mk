TAG = dockermk-concat
MAINTAINER = Jon Brisbin <jon@jbrisbin.com>
CMD = ["bash"]
OVERLAYS = utils first second third

include ../docker.mk

OVERLAY_DIRS += ubuntu

.PHONY = test-concat test-other

test-concat: clean install
	GREETING=`docker run -i $(TAG) cat /etc/config`; \
	[ "hello world!" == "$$GREETING" ]
