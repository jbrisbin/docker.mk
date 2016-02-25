TAG 				          := dockermk-java
FROM 				          := jbrisbin/trusty-minimal
ENTRYPOINT            := java -version

DOCKERFILE            := java.Dockerfile

OVERLAYS              := docker.mk/ubuntu/java8

include ../docker.mk
