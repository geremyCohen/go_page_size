#!/bin/bash
set -e

# Define paths
XGBOOST_DIR="$(pwd)/xgboost"
BUILD_DIR="$(pwd)/../ai_build"
ARTIFACTS_DIR="${BUILD_DIR}/artifacts"

# Create build directories
mkdir -p "${BUILD_DIR}"
mkdir -p "${ARTIFACTS_DIR}"

# Build XGBoost with JNI support
cd "${XGBOOST_DIR}"

# Configure with CMake
mkdir -p build
cd build
cmake .. -DJVM_BINDINGS=ON -DUSE_CUDA=OFF -DUSE_OPENMP=ON

# Build
make -j$(nproc)

# Build JVM packages with Maven
cd ../jvm-packages
mvn -q clean package -DskipTests

# Copy artifacts to the artifacts directory
cp -v xgboost4j/target/xgboost4j-*.jar "${ARTIFACTS_DIR}/"
cp -v ../lib/libxgboost4j.so "${ARTIFACTS_DIR}/" 2>/dev/null || echo "No libxgboost4j.so found"
find ../lib -name "*.so" -exec cp -v {} "${ARTIFACTS_DIR}/" \;

echo "Build completed. Artifacts are in ${ARTIFACTS_DIR}"
