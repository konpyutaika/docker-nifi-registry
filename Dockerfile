ARG VERSION=1.18.0
FROM apache/nifi-registry:${VERSION}
ARG VERSION=1.18.0

COPY sh/ ${NIFI_REGISTRY_BASE_DIR}/scripts/

### CUSTOMIZATION
# Install MySQL JDBC Driver
ARG MYSQL_DRIVER_VERSION=8.0.29
ARG MYSQL_DRIVER_BINARY_PATH="https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_DRIVER_VERSION/mysql-connector-java-$MYSQL_DRIVER_VERSION.jar"
RUN curl -fSL "${MYSQL_DRIVER_BINARY_PATH}" -o "$NIFI_REGISTRY_BASE_DIR/nifi-registry-$VERSION/lib/mysql-connector-java-$MYSQL_DRIVER_VERSION.jar" \
    && chown -R nifi:nifi "$NIFI_REGISTRY_BASE_DIR/nifi-registry-$VERSION/lib/mysql-connector-java-$MYSQL_DRIVER_VERSION.jar"

