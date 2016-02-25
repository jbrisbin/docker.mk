ENV \
  DEBIAN_FRONTEND=noninteractive \
  DEBCONF_NONINTERACTIVE_SEEN=true

# Install Java 8
RUN \
  apt-get update && \
  apt-get install -y git curl build-essential && \
  apt-get dist-upgrade -y
