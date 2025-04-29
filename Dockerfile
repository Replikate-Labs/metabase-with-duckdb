ARG METABASE_VERSION=latest
FROM metabase/metabase:${METABASE_VERSION}

# re-declare your build-arg so it's in scope for all following RUNs
ARG DUCKDB_DRIVER_VERSION=0.3.0

USER root

# install the minimal glibc shim and curl
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk update \
 && apk add --no-cache \
      libc6-compat \
      libstdc++ \
      gcompat \
      curl

# debug: print out the version so you can see it's set
RUN echo ">>> DUCKDB_DRIVER_VERSION=${DUCKDB_DRIVER_VERSION}"

# pull in the correct DuckDB driver
RUN mkdir -p /plugins \
 && curl -fSL \
      "https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar" \
      -o /plugins/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/plugins

USER metabase
