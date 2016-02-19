# Install Apache Mesos
RUN add-apt-repository "deb http://repos.mesosphere.io/ubuntu/ trusty main"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get update
RUN apt-get install -q -y mesos=$MESOS_VERSION
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos.so
