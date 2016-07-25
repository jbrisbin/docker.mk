# Simple overlay-based Dockerfile Generation

`docker.mk` is a helper for GNU `make` that simplifies the process of creating Docker images from a core set of template fragments. It lets you mix and match bits of a `Dockerfile` in different ways in order to not repeat yourself by cut-and-paste sharing of entire Dockerfiles. The core utility of `docker.mk` is `dockermk`, a small utility written in [Go](https://golang.org/) that finds the appropriate parts of the `Dockerfile` being generated based on parameters passed in and runs the entire mess though [Go's `template` library](https://golang.org/pkg/text/template/). You can define reusable template fragments in one overlay and repeat them in another.

### Installation

To install `docker.mk` and start using it to build your own Docker containers, just download the Makefile from GitHub. You can do this with curl:

```
$ curl -sL -O https://raw.githubusercontent.com/jbrisbin/docker.mk/master/docker.mk
```

You can start creating Docker containers very easily by specifying a minimal amount of metadata. Create a `Makefile` and add the following, altered to suit your needs:

```
TAG = myuser/my-awesome-container
MAINTAINER = John Doe <john.doe@gmail.com>

include ./docker.mk
```

_Note: if `TAG` is omitted, the name of the directory your `Makefile` is in will be used._

When you run `make`, `docker.mk` will first check to make sure you have the `dockermk` utility downloaded alongside the `docker.mk` file and if it's not, it will be downloaded automatically. `docker.mk` will then invoke the generation utility with the appropriate flags based on the values specified in the `Makefile` and including sensible defaults for optional settings. Since we've included no `OVERLAYS`, this example Docker container won't do anything interesting other than create an `alpine`-based image with the given tag. It's now runnable via `docker run --rm -it myuser/my-awesome-container sh`, though.

### Usage

`docker.mk` really pays dividends when you start breaking up your various Docker images into reusable components. It's not always practical to create images from a hierarchy of parent base images that descend from one another. Sometimes you want to install the same thing onto various images that descend from different bases (e.g. one for Alpine, one for Ubuntu, one for CentOS). If installing yours tools is the same for all types of OSes (e.g. if you use Java, Scala, Go, or other cross-platform languages), you can define an overlay that installs your tools and share it among your various Dockerfiles by including that overlay like a template.

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
MAINTAINER = John Doe <john.doe@gmail.com>
OVERLAYS = base

include ./docker.mk
```

If we run `make Dockerfile`, we should see our `Dockerfile` contain the two `apt-get` commands from the `base` overlay, which will be included in our Docker image. We can do a `docker build` on this file directly, or we can let `docker.mk` handle that by running `make install`, which does a `docker build`.

### Overlay Reuse

Overlays can be reused a number of different ways. Likely the most useful will be when they are used as templates that can install software for different OSes. Although a `Dockerfile` has a facility for passing an `ARG` to influence the build, it's hard to conditionally include portions of `Dockerfile` like including certain development libraries or different versions of a library based on your build or test needs.

#### Parameterizing Docker builds

To create a `build-essential` image that can be used to build software, you might create a set of overlays like the following:

```
mkdir -p alpine ubuntu centos

cat <<EOF >alpine/base.Dockerfile
RUN apk update
RUN apk add python3-dev build-base py-pip
EOF

cat <<EOF >ubuntu/base.Dockerfile
RUN apt-get update
RUN apt-get install -y python3-dev build-essential python3-pip
EOF

cat <<EOF >centos/base.Dockerfile
RUN yum install -y epel-release
RUN yum install -y python34-devel make automake gcc gcc-c++ python-pip
EOF
```

Then you can create a simple `Makefile` that specifies the `base` overlay and set `OVERLAY_DIRS` to the value of `FROM`, which we will change each time we run `make` by setting an environment variable:

```
cat <<EOF >Makefile
TAG = ci-build-essential
OVERLAY_DIRS = $(FROM)
OVERLAYS = base

include docker.mk
EOF

FROM=alpine make install
FROM=ubuntu make install
FROM=centos make install
```

_Note: the line that includes `FROM=alpine` is technically not necessary since `alpine` is the default `FROM` value._

After running `make install`, we'll have an image we can run named `ci-build-essential`. We can then build our source code by doing a `docker run -v $(pwd):/usr/src` and building our project in the `/usr/src` directory.

### Using Go Templates in overlays

`docker.mk` accumulates all the overlays defined in the `Makefile` and creates a single template that corresponds to the `Dockerfile` being output. Besides plain text, each overlay file can contain [Go template code](https://golang.org/pkg/text/template/). The full functionality of Go templates are supported. It's possible to include an overlay that has no text inside it but only template definitions that can be used later.

As an example of using a Go template in an overlay, we can add a bit of Go template to the end of the package install to also install any packages defined in a `PKGS` environment variable.

```
RUN apt-get update
RUN apt-get install -y python3-dev build-essential python3-pip {{index .Env "PKGS"}}
```

If you wanted to install `nano` into this image in order to edit files, you could add that to the `PKGS` environment variable and then run `make`:

```
PKGS=nano make install
```
