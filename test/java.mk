TAG 				          := dockermk-java
FROM 				          := jbrisbin/trusty-minimal
ENTRYPOINT            := java -version

DOCKERFILE            := java.Dockerfile

SHARED_OVERLAYS_DIR   := ../..
SHARED_OVERLAYS       := java8

include ../docker.mk
