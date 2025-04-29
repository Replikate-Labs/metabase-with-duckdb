############################
# build-time args
############################
ARG METABASE_VERSION=v0.54.4.x


############################
# Runtime stage = official Metabase image
############################
FROM metabase/metabase:${METABASE_VERSION}

ARG DUCKDB_DRIVER_VERSION
ARG DEB_GLIBC_VER
USER root

ARG DUCKDB_DRIVER_VERSION=0.3.0
ARG DEB_GLIBC_VER=2.41-7

# 1️⃣ bring in wget & friends
RUN apk add --no-cache wget ca-certificates tar xz libstdc++

# 2️⃣ pull glibc straight from Debian sid and lay it over /usr/glibc-compat
RUN set -eux; \
    wget -q http://deb.debian.org/debian/pool/main/g/glibc/libc6_${DEB_GLIBC_VER}_amd64.deb; \
    ar x libc6_${DEB_GLIBC_VER}_amd64.deb data.tar.xz; \
    tar -C / -xJf data.tar.xz ./usr/lib/x86_64-linux-gnu; \
    mv /usr/lib/x86_64-linux-gnu /usr/glibc-compat/lib; \
    # expose the new loader everywhere native libs look
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2; \
    mkdir -p /lib64 && \
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2; \
    rm -f libc6_${DEB_GLIBC_VER}_amd64.deb data.tar.xz

# 3️⃣ MotherDuck driver
RUN mkdir -p /plugins && \
    wget -q -O /plugins/duckdb.metabase-driver.jar \
         https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/plugins
USER metabase
