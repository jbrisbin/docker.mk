# Overlays are snippets of Dockerfiles that can be parameterized and overridden

define source_overlay
$(shell [ -f "$(1)" ] && cat $(1) | grep '^#:mk' | sed 's/^#:mk\(.*\)/$$\(eval \1\)/')
endef

define add_overlay
grep -v '^#:mk' $(1) | sed "s#\$$CURDIR/#$(dir $(realpath $(1)))#" | sed "s#$(CURDIR)/##" >>$(DOCKERFILE);
endef
