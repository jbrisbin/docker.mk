# Global verbosity settings
V ?= 0

verbose_0 = @
verbose_2 = set -x;
verbose = $(verbose_$(V))

# BUILD verbosity settings
build_verbose_0 = @echo " BUILD   " $(TAG);
build_verbose_2 = set -x;
build_verbose = $(build_verbose_$(V))

# OVERLAY verbosity settings
overlay_verbose_0 = @echo " OVERLAY " $(OVERLAYS);
overlay_verbose_2 = set -x;
overlay_verbose = $(overlay_verbose_$(V))
