TAG = test-get
OVERLAYS = get cut
CMD = ["echo", "$$JENKINS_HOME"]

test-get: clean install
	GREETING=`docker run --rm -i $(TAG) cat /etc/greeting`; \
	[ "hello world" == "$$GREETING" ]

test-cut:
	JENKINS_HOME=`docker run --rm -i $(TAG) sh -c 'echo $$JENKINS_HOME'`; \
	[ "/var/jenkins_home" == "$$JENKINS_HOME" ]

include ../docker.mk
