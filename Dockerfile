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


# tools we need: wget, dpkg (for dpkg-deb), xz for .deb payload
RUN apk add --no-cache wget dpkg xz libstdc++ ca-certificates

# overlay modern glibc (loader lives in /lib/x86_64-linux-gnu)
RUN set -eux; \
    wget -q "http://ftp.debian.org/debian/pool/main/g/glibc/libc6_${DEB_GLIBC_VER}_amd64.deb"; \
    dpkg-deb -x "libc6_${DEB_GLIBC_VER}_amd64.deb" /tmp/glibc; \
    find /tmp/glibc -type d | sort; \
    mkdir -p /usr/glibc-compat/lib; \
    # check for possible paths where libs might be located
    if [ -d "/tmp/glibc/lib/x86_64-linux-gnu" ]; then \
        cp -a /tmp/glibc/lib/x86_64-linux-gnu/* /usr/glibc-compat/lib/; \
    elif [ -d "/tmp/glibc/usr/lib/x86_64-linux-gnu" ]; then \
        cp -a /tmp/glibc/usr/lib/x86_64-linux-gnu/* /usr/glibc-compat/lib/; \
    elif [ -d "/tmp/glibc/lib64" ]; then \
        cp -a /tmp/glibc/lib64/* /usr/glibc-compat/lib/; \
    fi; \
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
