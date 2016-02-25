# Apache Mesos 0.26
ENV \
  MESOS_VERSION=${MESOS_VERSION:-0.26.0-0.2.145.ubuntu1404}

RUN \
  echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesos.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
  apt-get update && \
  apt-get install -y mesos=$MESOS_VERSION
ENV \
  MESOS_NATIVE_JAVA_LIBRARY=/usr/lib/libmesos.so \
  MESOS_NATIVE_LIBRARY=/usr/lib/libmesos.so
