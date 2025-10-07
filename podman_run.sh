#!/bin/zsh

# Container name
CONTAINER_NAME="talks-wiremock-contacts-api"

# Check if container exists (running or stopped) and remove it
if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Removing existing container: ${CONTAINER_NAME}"
    podman rm -f ${CONTAINER_NAME}
fi

# Run the new container
podman run -p 8081:8081 --name ${CONTAINER_NAME} -d marcelo10/talks-wiremock-contacts-api:latest