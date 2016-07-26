TAG = test-ifdef
OVERLAY_DIRS = .
OVERLAYS = defined
CMD = echo $$(cat /etc/greeting)

install:: export GREETING=world

test-ifdef: clean install
	GREETING=`docker run --rm -i $(TAG)`; \
	[ "hello world" == "$$GREETING" ]

-include ../docker.mk
