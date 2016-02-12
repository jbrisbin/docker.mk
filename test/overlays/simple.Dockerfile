#:mk DOCKER_BUILD_OPTS += --build-arg=SCRIPT=test.sh
#:mk DOCKER_TEST_OPTS += -e MY_VAR=something
ARG SCRIPT
ADD $CURDIR/$SCRIPT /
