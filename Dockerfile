############################
#  build-time parameters   #
############################
ARG METABASE_VERSION=v0.52.9        # pin to the last MB release that driver 0.3.0 is QA-ed against
ARG DUCKDB_DRIVER_VERSION=0.3.0     # or bump when MotherDuck ships 0.4.x

############################
#  runtime image           #
############################
FROM eclipse-temurin:17-jre-jammy AS runtime
# Temurin = Debian + glibc → DuckDB JNI loads, no 502s

############################
#  non-root metabase user  #
############################
RUN useradd -u 1000 -ms /bin/bash metabase

############################
#  install Metabase + MD   #
############################
# 1) Metabase JAR
ADD https://downloads.metabase.com/${METABASE_VERSION#v}/metabase.jar /opt/metabase/metabase.jar

# 2) MotherDuck driver
RUN mkdir -p /opt/metabase/plugins && \
    curl -fsSL \
      https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar \
      -o /opt/metabase/plugins/duckdb.metabase-driver.jar && \
    chmod 644 /opt/metabase/plugins/duckdb.metabase-driver.jar && \
    chown -R metabase:metabase /opt/metabase

############################
#  runtime config          #
############################
ENV MB_PLUGINS_DIR=/opt/metabase/plugins \
    MB_JETTY_PORT=3000       # change if you front-it with nginx on another port

USER metabase
WORKDIR /opt/metabase
EXPOSE 3000
ENTRYPOINT ["java","-jar","/opt/metabase/metabase.jar"]
