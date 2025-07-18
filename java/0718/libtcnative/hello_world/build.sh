#!/bin/bash
set -e

# Define paths
WORK_DIR="/home/ubuntu/go_page_size/java/0718/libtcnative"
HELLO_WORLD_DIR="${WORK_DIR}/hello_world"
BUILD_DIR="${HELLO_WORLD_DIR}/build"

# Create build directory if it doesn't exist
mkdir -p "${BUILD_DIR}"

# Compile the Java code
echo "Compiling Java code..."
javac -d "${BUILD_DIR}" "${HELLO_WORLD_DIR}/src/main/java/org/apache/tomcat/jni/Library.java" "${HELLO_WORLD_DIR}/src/main/java/HelloWorldJNI.java"

echo "Build completed successfully!"
