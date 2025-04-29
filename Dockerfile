############################
# build-time args
############################
ARG METABASE_VERSION=v0.54.4.x


############################
# Runtime stage – Alpine Metabase
############################
FROM metabase/metabase:${METABASE_VERSION}

ARG DUCKDB_DRIVER_VERSION=0.3.0
ARG DEB_GLIBC_VER=2.41-7

USER root

# tools we need: wget, dpkg (for dpkg-deb), xz for .deb payload
RUN apk add --no-cache wget dpkg xz libstdc++ ca-certificates

# overlay modern glibc (loader lives in /lib/x86_64-linux-gnu)
RUN set -eux; \
    wget -q "http://deb.debian.org/debian/pool/main/g/glibc/libc6_${DEB_GLIBC_VER}_amd64.deb"; \
    dpkg-deb -x "libc6_${DEB_GLIBC_VER}_amd64.deb" /tmp/glibc; \
    mkdir -p /usr/glibc-compat/lib; \
    # copy all libs into compat dir
    cp -a /tmp/glibc/lib/x86_64-linux-gnu/* /usr/glibc-compat/lib/; \
    # expose the new loader everywhere native libs look
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2; \
    mkdir -p /lib64 && \
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2; \
    rm -rf /tmp/glibc "libc6_${DEB_GLIBC_VER}_amd64.deb"

# MotherDuck (DuckDB) Metabase driver
RUN mkdir -p /plugins && \
    wget -q -O /plugins/duckdb.metabase-driver.jar \
         "https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar"

ENV MB_PLUGINS_DIR=/plugins
USER metabase
