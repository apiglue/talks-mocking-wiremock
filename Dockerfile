# Use a minimal Java JRE base image
FROM eclipse-temurin:21-jre-alpine

# Set WireMock version
ARG WIREMOCK_VERSION=3.13.1

# Set working directory
WORKDIR /wiremock

# Download the latest WireMock standalone JAR
# Using a specific version for reproducibility - update this to the latest version as needed
RUN apk add --no-cache curl && \
    curl -L https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/${WIREMOCK_VERSION}/wiremock-standalone-${WIREMOCK_VERSION}.jar \
    -o wiremock-standalone.jar && \
    apk del curl

# Expose WireMock on port 8081
EXPOSE 8081

# Create directories for mappings and files
RUN mkdir -p /wiremock/__files /wiremock/mappings

# Copy local mappings and files into the container
COPY mappings/ /wiremock/mappings/
COPY __files/ /wiremock/__files/

# Run WireMock
ENTRYPOINT ["java", "-jar", "wiremock-standalone.jar"]
CMD ["--port", "8081", "--verbose"]

#ENTRYPOINT exec java $JAVA_OPTS @FW_OPTS -Djava.security.egd=file:/dev/./urandom -jar wiremock-standalone.jar --port 8081 --verbose --supported-proxy-encodings=gzip,deflate