TAG = dockermk-concat
MAINTAINER = Jon Brisbin <jon@jbrisbin.com>
CMD = ["sh"]
OVERLAYS = utils first second third

include ../docker.mk

OVERLAY_DIRS += ubuntu

.PHONY = test-concat

install:: export HELLO = world

test-concat: clean install
	GREETING=`docker run -i $(TAG) cat /etc/config`; \
	[ "hello world!" == "$$GREETING" ]

test-envvar: 
	GREETING=`docker run -i $(TAG) cat /etc/greeting`; \
	[ "hello world" == "$$GREETING" ]
