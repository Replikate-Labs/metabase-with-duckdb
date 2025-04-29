############################
# build-time arguments     #
############################
ARG METABASE_VERSION=v0.54.4.x     # <-- drop the extra “.x”
ARG DUCKDB_DRIVER_VERSION=0.3.0  # 0.3.0 is still the latest

############################
# runtime image            #
############################
FROM eclipse-temurin:17-jre-jammy AS runtime   # glibc base, multi-arch

############################
# non-root user            #
############################
RUN useradd -u 1000 -ms /bin/bash metabase

############################
# install Metabase + driver#
############################
ADD https://downloads.metabase.com/${METABASE_VERSION#v}/metabase.jar \
    /opt/metabase/metabase.jar

RUN mkdir -p /opt/metabase/plugins && \
    curl -fsSL \
      https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar \
      -o /opt/metabase/plugins/duckdb.metabase-driver.jar && \
    chmod 644 /opt/metabase/plugins/duckdb.metabase-driver.jar && \
    chown -R metabase:metabase /opt/metabase

############################
# runtime env              #
############################
ENV MB_PLUGINS_DIR=/opt/metabase/plugins \
    MB_JETTY_PORT=3000

USER metabase
WORKDIR /opt/metabase
EXPOSE 3000
ENTRYPOINT ["java","-jar","/opt/metabase/metabase.jar"]
