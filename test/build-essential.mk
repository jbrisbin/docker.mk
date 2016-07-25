TAG = test-build-essential
OVERLAY_DIRS = $(FROM)
OVERLAYS = base

test-build-essential: clean install
	docker run --rm -i $(TAG) ls /usr/lib/lib*

include ../docker.mk
