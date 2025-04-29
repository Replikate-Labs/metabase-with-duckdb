ARG METABASE_VERSION=latest
ARG DUCKDB_DRIVER_VERSION=0.3.0

FROM metabase/metabase:${METABASE_VERSION}

USER root

# 1) enable edge/testing repo so we can install gcompat (glibc shim)
# 2) install libc6-compat (basic glibc libs), libstdc++ (for C++ std libs) & gcompat (dynamic linker)
# 3) install curl so we can fetch the DuckDB driver
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk update \
 && apk add --no-cache \
      libc6-compat \
      libstdc++ \
      gcompat \
      curl

# 4) create plugins dir and pull in the DuckDB Metabase driver
RUN mkdir -p /plugins \
 && curl -fSL \
      https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar \
      -o /plugins/duckdb.metabase-driver.jar

# point Metabase at your new plugin folder
ENV MB_PLUGINS_DIR=/plugins

USER metabase
