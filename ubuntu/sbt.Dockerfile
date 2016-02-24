RUN add-apt-repository -y "deb https://dl.bintray.com/sbt/debian /"
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
RUN apt-get update
RUN apt-get install -q -y sbt
