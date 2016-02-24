ENV GLIBC_VERSION 2.22-r8
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 74
ENV JAVA_VERSION_BUILD 02
ENV JAVA_PACKAGE       jdk

RUN curl -Ls https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.22-r8/glibc-${GLIBC_VERSION}.apk > /tmp/glibc-${GLIBC_VERSION}.apk \
  && apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk \
  && rm /tmp/*

RUN mkdir /opt \
  && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie"\
   http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz | tar -xzf - -C /opt \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/java \
  && rm -rf /opt/java/*src.zip \
            /opt/java/lib/missioncontrol \
            /opt/java/lib/visualvm \
            /opt/java/lib/*javafx* \
            /opt/java/jre/lib/plugin.jar \
            /opt/java/jre/lib/ext/jfxrt.jar \
            /opt/java/jre/bin/javaws \
            /opt/java/jre/lib/javaws.jar \
            /opt/java/jre/lib/desktop \
            /opt/java/jre/plugin \
            /opt/java/jre/lib/deploy* \
            /opt/java/jre/lib/*javafx* \
            /opt/java/jre/lib/*jfx* \
            /opt/java/jre/lib/amd64/libdecora_sse.so \
            /opt/java/jre/lib/amd64/libprism_*.so \
            /opt/java/jre/lib/amd64/libfxplugins.so \
            /opt/java/jre/lib/amd64/libglass.so \
            /opt/java/jre/lib/amd64/libgstreamer-lite.so \
            /opt/java/jre/lib/amd64/libjavafx*.so \
            /opt/java/jre/lib/amd64/libjfx*.so

ENV JAVA_HOME /opt/java
ENV PATH ${PATH}:${JAVA_HOME}/bin
