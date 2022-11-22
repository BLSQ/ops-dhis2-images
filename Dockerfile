FROM openjdk:11-jdk
WORKDIR /root/

RUN  apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
# install dockerize
ENV DOCKERIZE_VERSION v0.5.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz
# install jvm-mon
ENV JVM_MON_VERSION 0.3
RUN wget https://github.com/ajermakovics/jvm-mon/releases/download/$JVM_MON_VERSION/jvm-mon-$JVM_MON_VERSION.tar.gz \
    && tar -C / -xzvf jvm-mon-$JVM_MON_VERSION.tar.gz \
    && rm jvm-mon-$JVM_MON_VERSION.tar.gz
# install webapp runner
ENV WEBAPP_RUNNER_VERSION 8.5.51.0
RUN wget https://repo.maven.apache.org/maven2/com/heroku/webapp-runner-main/${WEBAPP_RUNNER_VERSION}/webapp-runner-main-${WEBAPP_RUNNER_VERSION}.jar -O webapp-runner.jar
# install dhis2 version 2.34
ARG DHIS2_VERSION
# to trigger a rebuild eg 2.34.7-EMBARGOED
ARG DHIS2_FULL_VERSION
RUN echo ${DHIS2_VERSION} ${DHIS2_FULL_VERSION}
ADD ./releases/dhis2-stable-$DHIS2_FULL_VERSION.war dhis.war
# start process
EXPOSE 8080
COPY ./templates .
CMD export DHIS2_HOME=. && dockerize -template ./log4j.properties.tmpl:./log4j.properties -template ./dhis.conf.tmpl:./dhis.conf java $JAVA_OPTS -Dfile.encoding=UTF-8 -Dlog4j.configuration=file:/root/log4j.properties -Dlog4j.configurationFile=file:/root/log4j.properties -Djava.awt.headless=true -Dlog4j2.formatMsgNoLookups=true -cp ./:./webapp-runner.jar webapp.runner.launch.Main --expand-war-file true --port 8080 dhis.war -ArelaxedQueryChars='\ { } | [ ]'
