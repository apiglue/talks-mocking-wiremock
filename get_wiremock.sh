#!/bin/zsh

# WireMock version to download
WIREMOCK_VERSION="3.13.1"

# WireMock JAR filename
WIREMOCK_JAR="wiremock-standalone-${WIREMOCK_VERSION}.jar"

# Maven Central URL for WireMock standalone JAR
WIREMOCK_URL="https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/${WIREMOCK_VERSION}/${WIREMOCK_JAR}"

echo "Downloading WireMock ${WIREMOCK_VERSION}..."

# Check if the JAR file already exists
if [ -f "${WIREMOCK_JAR}" ]; then
    echo "WireMock ${WIREMOCK_VERSION} already exists at ${WIREMOCK_JAR}"
    exit 0
fi

# Download the JAR file
if command -v curl >/dev/null 2>&1; then
    curl -L -o "${WIREMOCK_JAR}" "${WIREMOCK_URL}"
elif command -v wget >/dev/null 2>&1; then
    wget -O "${WIREMOCK_JAR}" "${WIREMOCK_URL}"
else
    echo "Error: Neither curl nor wget is available. Please install one of them."
    exit 1
fi

# Check if download was successful
if [ $? -eq 0 ] && [ -f "${WIREMOCK_JAR}" ]; then
    echo "Successfully downloaded WireMock ${WIREMOCK_VERSION} to ${WIREMOCK_JAR}"
else
    echo "Failed to download WireMock ${WIREMOCK_VERSION}"
    exit 1
fi