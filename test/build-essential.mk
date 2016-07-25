TAG = test-build-essential
OVERLAY_DIRS = $(FROM)
OVERLAYS = base
CMD = ["ls", "-l", "/usr/lib/gcc/x86_64-linux-gnu/4.8/libstdc++.a"]

install:: export FROM = ubuntu
	
test-build-essential: clean install
	SIZE=`docker run --rm -i $(TAG) | awk '{print $$5}'`; \
	[ "2900774" == "$$SIZE" ]

include ../docker.mk
