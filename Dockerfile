############################
# build-time arguments     #
############################
ARG METABASE_VERSION=v0.54.4.x


############################
# Stage 0 – extract JAR    #
############################
FROM metabase/metabase:${METABASE_VERSION} AS metabase-src

ARG DUCKDB_DRIVER_VERSION=0.3.0

ARG GLIBC_VERSION=2.39-r0

USER root

### 1. Upgrade to modern glibc ###
RUN set -eux; \
    apk add --no-cache curl wget libc6-compat libstdc++; \
    # import sgerrand signing key
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
         https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    # download glibc APKs
    for p in glibc glibc-bin glibc-i18n; do \
      wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${p}-${GLIBC_VERSION}.apk; \
    done; \
    # install, clobbering musl duplicates
    apk --no-cache --force-overwrite add \
        glibc-${GLIBC_VERSION}.apk \
        glibc-bin-${GLIBC_VERSION}.apk \
        glibc-i18n-${GLIBC_VERSION}.apk; \
    # generate locale needed by JVM
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 || true; \
    # loader symlinks for native libs
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2; \
    mkdir -p /lib64 && \
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2; \
    # tidy up APKs
    rm -f *.apk

### 2. MotherDuck (DuckDB) Metabase driver ###
RUN set -eux; \
    mkdir -p /plugins && \
    curl -fsSL -o /plugins/duckdb.metabase-driver.jar \
      https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar

ENV MB_PLUGINS_DIR=/plugins

USER metabase
