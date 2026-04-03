FROM eclipse-temurin:17

# create non-root user early so COPY --chown can use it (avoids chown layer duplication)
RUN groupadd --gid 1001 appuser && useradd --uid 1001 --gid appuser --shell /bin/bash --create-home appuser

# create target directory using non-root user
RUN mkdir -p /opt/dhis2 && chown appuser:appuser /opt/dhis2    
RUN mkdir -p /opt/dhis2/target && chown appuser:appuser /opt/dhis2/target

WORKDIR /opt/dhis2

# install dependencies
RUN  apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# install jvm-mon
ENV JVM_MON_VERSION=0.3
RUN wget https://github.com/ajermakovics/jvm-mon/releases/download/$JVM_MON_VERSION/jvm-mon-$JVM_MON_VERSION.tar.gz \
    && tar -C / -xzvf jvm-mon-$JVM_MON_VERSION.tar.gz \
    && rm jvm-mon-$JVM_MON_VERSION.tar.gz

# install webapp runner
ENV WEBAPP_RUNNER_VERSION=10.1.46.0
RUN wget https://repo.maven.apache.org/maven2/com/heroku/webapp-runner-main/${WEBAPP_RUNNER_VERSION}/webapp-runner-main-${WEBAPP_RUNNER_VERSION}.jar -O webapp-runner.jar

# add dhis2 version
ARG DHIS2_VERSION

# add dhis2 war file
ARG DHIS2_FULL_VERSION
RUN echo ${DHIS2_VERSION} ${DHIS2_FULL_VERSION}
ADD --chown=appuser:appuser ./releases/dhis2-stable-$DHIS2_FULL_VERSION.war dhis.war

# copy entry point
COPY --chown=appuser:appuser ./entry_point.sh ./entry_point.sh

# change ownership of target directory to non-root user
RUN chown -R appuser:appuser /opt/dhis2

# switch to non-root user
USER appuser

# start process
EXPOSE 8080
RUN chmod +x ./entry_point.sh

ENTRYPOINT ["./entry_point.sh"]