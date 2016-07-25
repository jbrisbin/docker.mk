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

When you run `make`, `docker.mk` will first check to make sure you have the `dockermk` utility downloaded alongside the `docker.mk` file and if it's not, it will be downloaded automatically. `docker.mk` will then invoke the generation utility with the appropriate flags based on the values specified in the `Makefile` and including sensible defaults for optional settings. Since we've included no `OVERLAYS`, this example Docker container won't do anything interesting. It's now runnable via `docker run --rm myuser/my-awesome-container`, though.

### Usage

`docker.mk` really pays dividends when you start breaking up your various Docker images into reusable components. It's not always practical to create images from a hierarchy of parent base images that descend from one another. Sometimes you want to install the same thing onto various images that descend from different bases (e.g. one for Alpine, one for Ubuntu, one for CentOS). Since installing these tools is the same for all types of OSes, you can define an overlay that installs your tools and share it among your various Dockerfiles by including that overlay like a template.

To create overlays, simply create a file with the pattern `name.Dockerfile` where `name` will be the name used to refer to your overlay. `docker.mk` recognizes that as an overlay due to the `.Dockerfile` suffix.

```
$ vi base.Dockerfile
RUN apt-get update
RUN apt-get install -y build-essential automake
:wq
```

To include this overlay in your image, just add a reference to it in the `OVERLAYS` variable in the `Makefile` defined above.

```
TAG = myuser/my-awesome-container
FROM = ubuntu
MAINTAINER = John Doe <john.doe@gmail.com>
OVERLAYS = base

include ./docker.mk
```

If we run `make Dockerfile`, we should see our `Dockerfile` contain the two `apt-get` commands from the `base` overlay, which will be included in our Docker image. We can do a `docker build` on this file directly, or we can let `docker.mk` handle that by running `make install`, which does a `docker build`.
