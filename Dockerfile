ARG METABASE_VERSION=latest
FROM metabase/metabase:${METABASE_VERSION}
ARG DUCKDB_DRIVER_VERSION=0.2.12-b

RUN mkdir -p /plugins && \
    curl -L -o /plugins/duckdb.metabase-driver.jar \
         https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/plugins
