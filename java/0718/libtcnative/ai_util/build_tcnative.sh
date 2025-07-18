#!/bin/bash
set -e

# Define paths
WORK_DIR="/home/ubuntu/go_page_size/java/0718/libtcnative"
SOURCE_DIR="${WORK_DIR}/tomcat-native"
BUILD_DIR="${WORK_DIR}/ai_build"
INSTALL_DIR="${BUILD_DIR}/install"

# Create build directory if it doesn't exist
mkdir -p "${BUILD_DIR}"
mkdir -p "${INSTALL_DIR}"

# Add cstdint header to source files that might need it
find "${SOURCE_DIR}/native/src" -name "*.c" -exec sed -i '1i\#include <cstdint>' {} \;

# Build using CMake
cd "${BUILD_DIR}"
cmake "${SOURCE_DIR}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DOPENSSL_ROOT_DIR=/usr \
  -DJAVA_HOME="${JAVA_HOME}" \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_STATIC_LIBS=OFF

# Compile
cmake --build . --config Release -j$(nproc)

# Install
cmake --install .

echo "Build completed successfully!"
