############################
# build-time arguments     #
############################
ARG METABASE_VERSION=v0.54.4.x


############################
# Stage 0 – extract JAR    #
############################
FROM metabase/metabase:${METABASE_VERSION} AS metabase-src

ARG DUCKDB_DRIVER_VERSION=0.3.0

##########################
# MotherDuck driver
RUN mkdir -p /plugins && \
    curl -fsSL \
      https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar \
      -o /plugins/duckdb.metabase-driver.jar && \
    chmod 644 /plugins/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/plugins
