#!/bin/bash

# List all containers (running and stopped)
echo "Listing all Docker containers:"
docker ps -a --format "table {{.ID}}	{{.Names}}	{{.Status}}	{{.Image}}"

echo ""
read -p "Enter the CONTAINER ID or NAME to remove: " CONTAINER_ID
read -p "Enter the IMAGE ID or NAME associated with this container: " IMAGE_ID

echo "Stopping container: $CONTAINER_ID"
docker stop "$CONTAINER_ID"

echo "Removing container: $CONTAINER_ID"
docker rm "$CONTAINER_ID"

echo "Removing image: $IMAGE_ID"
docker rmi "$IMAGE_ID"

echo "Done."
