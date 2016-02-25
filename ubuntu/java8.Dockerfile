# Install Java 8
RUN \
  echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main" > /etc/apt/sources.list.d/openjdk-r.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv 86F44E2A && \
  apt-get update && \
  apt-get install -y openjdk-8-jdk
