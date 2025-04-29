############################
# build-time args
############################
ARG METABASE_VERSION
ARG DUCKDB_DRIVER_VERSION

############################
# Runtime stage – Use Debian instead of Alpine for better glibc compatibility
############################
FROM eclipse-temurin:17-jre

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
