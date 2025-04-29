ARG METABASE_VERSION=latest
FROM metabase/metabase:${METABASE_VERSION}

# expose the driver-version arg after FROM so it’s in-scope
ARG DUCKDB_DRIVER_VERSION=0.3.0

USER root

# 1) install glibc shim + curl
# 2) add metabase user/group at UID/GID 1000
# 3) fetch the DuckDB driver and chown /plugins
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk update \
 && apk add --no-cache libc6-compat libstdc++ gcompat curl \
 && addgroup -g 1000 metabasegrp \
 && adduser  -u 1000 -G metabasegrp -D metabase \
 && mkdir -p /plugins \
 && curl -fSL \
      "https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar" \
      -o /plugins/duckdb.metabase-driver.jar \
 && chown -R 1000:1000 /plugins

# tell Metabase where to look
ENV MB_PLUGINS_DIR=/plugins

# finally drop to the new metabase user
USER metabase
