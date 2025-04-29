############################
# build-time arguments     #
############################
ARG METABASE_VERSION=v0.54.5.x


############################
# Stage 0 – extract JAR    #
############################
FROM metabase/metabase:${METABASE_VERSION} AS metabase-src

ARG DUCKDB_DRIVER_VERSION=0.3.0        # MotherDuck driver tag

##########################
# MotherDuck driver
RUN mkdir -p /opt/metabase/plugins && \
    curl -fsSL \
      https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar \
      -o /opt/metabase/plugins/duckdb.metabase-driver.jar && \
    chmod 644 /opt/metabase/plugins/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/opt/metabase/plugins
