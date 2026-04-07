# --- builder stage: download dockerize and webapp-runner ---------------------
FROM eclipse-temurin:17-jre AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# dockerize (used by the legacy / non-Kubernetes entry point to template dhis.conf and log4j.properties)
ENV DOCKERIZE_VERSION=v0.5.0
RUN wget -q https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# webapp runner
ENV WEBAPP_RUNNER_VERSION=10.1.46.0
RUN wget -q https://repo.maven.apache.org/maven2/com/heroku/webapp-runner-main/${WEBAPP_RUNNER_VERSION}/webapp-runner-main-${WEBAPP_RUNNER_VERSION}.jar -O /tmp/webapp-runner.jar


# --- Final stage: JDK runtime (jdk has extra tools like jstack and jps) --------------------------------------------
FROM eclipse-temurin:17-jdk

# create non-root user, target dirs, and set ownership in a single layer
RUN groupadd --gid 1001 appuser \
    && useradd --uid 1001 --gid appuser --shell /bin/bash --create-home appuser \
    && mkdir -p /opt/dhis2/target \
    && chown -R appuser:appuser /opt/dhis2

WORKDIR /opt/dhis2

# bring in the prebuilt binaries from the builder stage
COPY --from=builder /usr/local/bin/dockerize /usr/local/bin/dockerize
COPY --from=builder --chown=appuser:appuser /tmp/webapp-runner.jar ./webapp-runner.jar

# add dhis2 version
ARG DHIS2_VERSION
ARG DHIS2_FULL_VERSION
RUN echo ${DHIS2_VERSION} ${DHIS2_FULL_VERSION}

# add dhis2 war file
ADD --chown=appuser:appuser ./releases/dhis2-stable-$DHIS2_FULL_VERSION.war dhis.war

# templates (used by dockerize in the legacy / non-Kubernetes entry point)
COPY --chown=appuser:appuser ./templates ./

# entry point
COPY --chown=appuser:appuser --chmod=755 ./entry_point.sh ./entry_point.sh

USER appuser

EXPOSE 8080

ENTRYPOINT ["./entry_point.sh"]
