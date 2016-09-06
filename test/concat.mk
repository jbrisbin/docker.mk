TAG = dockermk-concat
MAINTAINER = Jon Brisbin <jon@jbrisbin.com>
CMD = ["sh"]
OVERLAYS = utils first second third
OS = ubuntu-14.04

include ../docker.mk

.PHONY: test-concat

install:: export HELLO = world

test-concat: clean install
	GREETING=`docker run -i $(TAG) cat /etc/config`; \
	[ "hello world!" == "$$GREETING" ]

test-envvar:
	GREETING=`docker run -i $(TAG) cat /etc/greeting`; \
	[ "hello world" == "$$GREETING" ]
