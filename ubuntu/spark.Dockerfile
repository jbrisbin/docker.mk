# Install Spark
RUN [ ! -d "/opt/$SPARK_DIRNAME" ] && curl -O $SPARK_TGZ
RUN tar zxvf $SPARK_DIRNAME.tgz -C /opt
ENV SPARK_HOME /opt/$SPARK_DIRNAME
