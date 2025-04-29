############################
# build-time arguments     #
############################
ARG METABASE_VERSION=v0.54.5.x         # keep the .x tag for Docker Hub
ARG DUCKDB_DRIVER_VERSION=0.3.0        # MotherDuck driver tag

############################
# Stage 0 – extract JAR    #
############################
FROM metabase/metabase:${METABASE_VERSION} AS metabase-src

############################
# Stage 1 – slim runtime   #
############################
FROM eclipse-temurin:17-jre-jammy AS runtime

# non-root user
RUN useradd -u 1000 -ms /bin/bash metabase

# copy Metabase JAR from stage 0
COPY --from=metabase-src /app/metabase.jar /opt/metabase/metabase.jar

# MotherDuck driver
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
