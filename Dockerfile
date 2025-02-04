FROM metabase/metabase:latest

# Download the driver using curl (which should be available in the base image)
RUN mkdir -p /plugins && \
    curl -L -o /plugins/duckdb.metabase-driver.jar \
    https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/0.2.12/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/plugins