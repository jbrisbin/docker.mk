# docker.mk

`docker.mk` is a make-based helper for composing a Dockerfile from "overlays", which are just portions of a Dockerfile that have been parameterized and are reusable. Overlays can be published on GitHub, in a Gist, or as plain-text on an HTTP-accessible server and downloaded at build time to eliminate the fragility of keeping many copies of Dockerfiles around.

### Installation

`docker.mk` is intended to be used from your own build and included into your own `Makefile`. If you don't want to keep a copy of it in your build but download it from GitHub as needed, then just add a simple target to your `Makefile`:

```make
docker.mk:
  @wget https://raw.githubusercontent.com/jbrisbin/docker.mk/master/docker.mk

-include docker.mk
```

### Configuration

Before including `docker.mk`, set up the configuration variables to influence how the `Dockerfile` gets built. The following variables are available:

* `TAG` (default: none) - The value passed to the `-t` flag when buiding the Docker image. Should reflect the full tag value, including user or repository and version. e.g. `jbrisbin/apache-zeppelin:0.5.6`
* `LABEL` (default: none) - Pairs of `label=value` which will be added to the docker image build.
* `FROM` (default: ubuntu) - Image used as the base. Will be inserted into the Dockerfile's `FROM` line.
* `MAINTAINER` (default: none) - Optional value of the `MAINTAINER` line in the Dockerfile. If not set, no `MAINTAINER` line will be added.
* `ENTRYPOINT` (default: none) - Optional value of the `ENTRYPOINT` line in the Dockerfile. If not set, no `ENTRYPOINT` line will be added.
* `OVERLAYS` (default: none) - Space-separated list of overlays to compose into the Dockerfile.
* `DOCKER_BUILD_OPTS` (default: none) - Additional options to pass to the `docker build` command.

There are additional variables that govern the building of a Dockerfile. These should only be changed if you know what you are doing.

* `DOCKERFILE` (default: Dockerfile) - Name of the file created and used to build the Docker image.
* `DOCKER_TEST_OPTS` (default: none) - Additional options to pass to the `docker run` command which runs the image defined in the `test/Makefile` file.
* `OVERLAYS_DIR` (default: overlays) - Subdirectory from which the overlays will be composed.

### Building the Image

A minimal `Makefile` to build a `Dockerfile` using `docker.mk` would need just a couple lines:

```make
TAG := dockerhubuser/docker-image-name:version
FROM := ubuntu:trusty
ENTRYPOINT := bash

docker.mk:
  @wget https://raw.githubusercontent.com/jbrisbin/docker.mk/master/docker.mk

-include docker.mk
```

To build the image, just run the `install` target:

```
$ make install
```

### Using Overlays

The real purpose of `docker.mk` is to help you break up the reusable portions of your Dockerfile into manageable chunks that can be source controlled and published outside the context of your Dockerfile. For example, if you wanted to install a particular software package in a certain way, using certain flags, you would create an overlay to encapsulate those build commands and publish just that portion of the Dockerfile as an overlay.

It's easy to include overlays directly inside your repository. To use an overlay included in your build, just add an entry to your `OVERLAYS` variable.

```
OVERLAYS := java8
```

This would compose into the Dockerfile the contents of `overlays/java8.Dockerfile`.
