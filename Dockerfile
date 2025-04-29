############################
# build-time args
############################
# Default values that will be overridden by build args
ARG METABASE_VERSION=v0.54.5
ARG DUCKDB_DRIVER_VERSION=0.3.0

############################
# Runtime stage – Use Debian with Java 21 for compatibility
############################
FROM eclipse-temurin:24-jre

# Pass ARGs from outer scope to inner scope
ARG METABASE_VERSION
ARG DUCKDB_DRIVER_VERSION

# Create plugins directory
RUN mkdir -p /plugins

# Install Metabase
RUN wget -q -O /metabase.jar "https://downloads.metabase.com/${METABASE_VERSION}/metabase.jar"

# Download MotherDuck (DuckDB) Metabase driver
RUN wget -q -O /plugins/duckdb.metabase-driver.jar \
     "https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/${DUCKDB_DRIVER_VERSION}/duckdb.metabase-driver.jar"

# Set environment variables
ENV MB_PLUGINS_DIR=/plugins

# Run Metabase
CMD ["java", "-jar", "/metabase.jar"]
