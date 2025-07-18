#!/bin/bash
set -e

# Define paths
WORK_DIR="/home/ubuntu/go_page_size/java/0718/libtcnative"
HELLO_WORLD_DIR="${WORK_DIR}/hello_world"
BUILD_DIR="${HELLO_WORLD_DIR}/build"

# Run the Java application
echo "Running Hello World JNI application..."
java -cp "${BUILD_DIR}" HelloWorldJNI

echo "Application execution completed!"
