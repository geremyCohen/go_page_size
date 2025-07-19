#!/bin/bash

# Script to create a Docker container named 3_libxgboost4j_1 and run the JDK17 install and hello world applications

set -e  # Exit on error

echo "=== XGBoost JDK17 Docker Container Setup and Test ==="
echo "This script will:"
echo "1. Create a Docker container named 3_libxgboost4j_1"
echo "2. Copy the JDK17 scripts to the container"
echo "3. Run the JDK17 installation script"
echo "4. Run the JDK17 hello world application"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Define container name
CONTAINER_NAME="3_libxgboost4j_1"

# Check if container with the same name already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container ${CONTAINER_NAME} already exists. Removing it..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Create artifacts directory if it doesn't exist
mkdir -p "${PARENT_DIR}/4/artifacts"

# Copy XGBoost artifacts to the artifacts directory
if [ -f "${PARENT_DIR}/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ] && [ -f "${PARENT_DIR}/ai_build/libxgboost.so" ]; then
    echo "Copying XGBoost artifacts from ai_build directory..."
    cp "${PARENT_DIR}/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" "${PARENT_DIR}/4/artifacts/"
    cp "${PARENT_DIR}/ai_build/libxgboost.so" "${PARENT_DIR}/4/artifacts/"
    
    # Copy libdmlc.so.0.6 if it exists
    if [ -f "${PARENT_DIR}/ai_build/libdmlc.so.0.6" ]; then
        echo "Copying libdmlc.so.0.6"
        cp "${PARENT_DIR}/ai_build/libdmlc.so.0.6" "${PARENT_DIR}/4/artifacts/"
        cd "${PARENT_DIR}/4/artifacts/"
        ln -sf libdmlc.so.0.6 libdmlc.so.0
    elif [ -f "${PARENT_DIR}/ai_build/libdmlc.so.0" ]; then
        echo "Copying libdmlc.so.0"
        cp "${PARENT_DIR}/ai_build/libdmlc.so.0" "${PARENT_DIR}/4/artifacts/"
    else
        echo "Warning: libdmlc.so.0 or libdmlc.so.0.6 not found in the ai_build directory"
        echo "The hello world application may fail to run if these libraries are not available"
    fi
else
    echo "XGBoost artifacts not found in ai_build directory. Please build XGBoost first."
    exit 1
fi

# Create Docker container
echo "Creating Docker container ${CONTAINER_NAME}..."
docker run -d --name "${CONTAINER_NAME}" -it ubuntu:latest

# Copy scripts to the container
echo "Copying scripts to the container..."
docker cp "${PARENT_DIR}/4/jdk17_install.sh" "${CONTAINER_NAME}:/root/jdk17_install.sh"
docker cp "${PARENT_DIR}/4/jdk17_hello_world_run.sh" "${CONTAINER_NAME}:/root/jdk17_hello_world_run.sh"
docker cp "${PARENT_DIR}/4/artifacts" "${CONTAINER_NAME}:/root/"

# Make scripts executable in the container
echo "Making scripts executable in the container..."
docker exec "${CONTAINER_NAME}" chmod +x /root/jdk17_install.sh /root/jdk17_hello_world_run.sh

# Install wget and python in the container
echo "Installing wget and python in the container..."
docker exec "${CONTAINER_NAME}" apt-get update
docker exec "${CONTAINER_NAME}" apt-get install -y wget python3 python-is-python3

# Run the JDK17 installation script
echo "Running JDK17 installation script in the container..."
docker exec "${CONTAINER_NAME}" /root/jdk17_install.sh

# Run the JDK17 hello world application
echo "Running JDK17 hello world application in the container..."
docker exec "${CONTAINER_NAME}" /root/jdk17_hello_world_run.sh

echo ""
echo "=== All done! ==="
echo "The JDK17 installation and hello world test have been completed successfully in container ${CONTAINER_NAME}."
echo "You can access the container with: docker exec -it ${CONTAINER_NAME} bash"
echo "To stop the container: docker stop ${CONTAINER_NAME}"
echo "To remove the container: docker rm ${CONTAINER_NAME}"
