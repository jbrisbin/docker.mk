RUN \
  add-apt-repository -y ppa:andrei-pozolotin/maven3 && \
  add-apt-repository -y ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -q -y openjdk-8-jdk maven3
