
# Overlay to install packages necessary to build software
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN apt-get update
RUN apt-get install -q -y apt-transport-https software-properties-common build-essential git
RUN apt-get dist-upgrade -y
