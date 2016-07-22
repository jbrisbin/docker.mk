# Simple overlay-based Dockerfile Generation

`docker.mk` is a helper for GNU `make` that simplifies the process of creating Docker images from a core set of template fragments. It lets you mix and match bits of a `Dockerfile` in different ways in order to not repeat yourself by cut-and-paste sharing of entire Dockerfiles. The core utility of `docker.mk` is `dockermk`, a small utility written in [Go](https://golang.org/) that finds the appropriate parts of the `Dockerfile` being generated based on parameters passed in and runs the entire mess though [Go's `template` library](https://golang.org/pkg/text/template/). You can define reusable template fragments in one overlay and repeat them in another.

### Installation

To install `docker.mk` and start using it to build your own Docker containers, just download the Makefile from GitHub. You can do this with curl:

```
$ curl -sL -O https://raw.githubusercontent.com/jbrisbin/docker.mk/master/docker.mk
```

You can start creating Docker containers very easily by specifying a minimal amount of metadata. Create a `Makefile` and add the following, altered to suit your needs (only `TAG` is really required as the others are omitted if left blank or are sensibly defaulted):

```
TAG = myuser/my-awesome-container
FROM = ubuntu
MAINTAINER = John Doe <john.doe@gmail.com>

include ./docker.mk
```

When you run `make`, `docker.mk` will invoke the generation utility with the appropriate flags based on the values specified in the `Makefile` and including sensible defaults for optional settings. Since we've included no `OVERLAYS`, this Docker container doesn't do anything interesting. It's now runnable via `docker run --rm myuser/my-awesome-container`.
