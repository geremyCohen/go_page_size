#!/bin/bash

# TensorFlow JNI Compilation Script for ARM64 Ubuntu 24
# This script automates the complete process of compiling TensorFlow with JNI support

set -e  # Exit on any error

echo "=== TensorFlow JNI Compilation Script for ARM64 ==="
echo "Starting compilation process..."
echo

# Configuration
TENSORFLOW_VERSION="v2.13.0"
JAVA_HOME_PATH="/usr/lib/jvm/java-11-openjdk-arm64"
BUILD_DIR="tensorflow"

# Function to print status messages
print_status() {
    echo ">>> $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists bazel; then
    echo "Error: Bazel is not installed. Please install Bazel first."
    exit 1
fi

if ! command_exists git; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

if [ ! -d "$JAVA_HOME_PATH" ]; then
    echo "Error: Java 11 not found at $JAVA_HOME_PATH"
    echo "Please install OpenJDK 11: sudo apt-get install openjdk-11-jdk"
    exit 1
fi

print_status "Prerequisites check passed!"

# Set environment variables
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

print_status "Java version: $(java -version 2>&1 | head -n1)"
print_status "Bazel version: $(bazel --version)"

# Clone TensorFlow if not exists
if [ ! -d "$BUILD_DIR" ]; then
    print_status "Cloning TensorFlow repository..."
    git clone https://github.com/tensorflow/tensorflow.git "$BUILD_DIR"
else
    print_status "TensorFlow repository already exists"
fi

cd "$BUILD_DIR"

# Checkout specific version
print_status "Checking out TensorFlow $TENSORFLOW_VERSION..."
git checkout "$TENSORFLOW_VERSION"

# Apply ARM64 fixes
print_status "Applying ARM64 compilation fixes..."

# Fix 1: tensorflow_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/tensorflow_jni.cc; then
    print_status "Adding cstdint header to tensorflow_jni.cc"
    sed -i '/#include "tensorflow\/java\/src\/main\/native\/tensorflow_jni.h"/a #include <cstdint>' tensorflow/java/src/main/native/tensorflow_jni.cc
fi

# Fix 2: tensor_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/tensor_jni.cc; then
    print_status "Adding cstdint header to tensor_jni.cc"
    sed -i '/#include "tensorflow\/java\/src\/main\/native\/tensor_jni.h"/a #include <cstdint>' tensorflow/java/src/main/native/tensor_jni.cc
fi

# Fix 3: session_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/session_jni.cc; then
    print_status "Adding cstdint header to session_jni.cc"
    sed -i '1i #include <cstdint>' tensorflow/java/src/main/native/session_jni.cc
fi

# Fix 4: cache.h
if ! grep -q "#include <cstdint>" tensorflow/tsl/lib/io/cache.h; then
    print_status "Adding cstdint header to cache.h"
    sed -i '/#ifndef TENSORFLOW_TSL_LIB_IO_CACHE_H_/a #define TENSORFLOW_TSL_LIB_IO_CACHE_H_\n\n#include <cstdint>' tensorflow/tsl/lib/io/cache.h
    sed -i '/#define TENSORFLOW_TSL_LIB_IO_CACHE_H_/d' tensorflow/tsl/lib/io/cache.h
fi

# Fix 5: denormal.cc
if ! grep -q "#include <cstdint>" tensorflow/tsl/platform/denormal.cc; then
    print_status "Adding cstdint header to denormal.cc"
    sed -i '/#include "tensorflow\/tsl\/platform\/denormal.h"/a #include <cstdint>' tensorflow/tsl/platform/denormal.cc
fi

# Configure TensorFlow
print_status "Configuring TensorFlow build..."
python3 configure.py <<EOF


n
n
n

n
EOF

# Build TensorFlow JNI
print_status "Building TensorFlow JNI libraries (this will take several hours)..."
print_status "Building Java JAR and JNI library..."
bazel build --config=opt //tensorflow/java:tensorflow //tensorflow/java:libtensorflow_jni

print_status "Building framework library..."
bazel build --config=opt //tensorflow:libtensorflow_framework.so

# Copy built artifacts
print_status "Copying built artifacts..."
cd ..

cp "$BUILD_DIR/bazel-bin/tensorflow/java/libtensorflow.jar" .
cp "$BUILD_DIR/bazel-bin/tensorflow/java/libtensorflow_jni.so" .
cp "$BUILD_DIR/bazel-bin/tensorflow/libtensorflow_framework.so" .

# Create versioned framework library
ln -sf libtensorflow_framework.so libtensorflow_framework.so.2

# Create complete JAR with embedded native libraries
print_status "Creating complete JAR with embedded native libraries..."
mkdir -p org/tensorflow/native/linux-aarch64
cp libtensorflow_jni.so org/tensorflow/native/linux-aarch64/
cp libtensorflow_framework.so.2 org/tensorflow/native/linux-aarch64/

# Extract original JAR and repackage with native libraries
jar -xf libtensorflow.jar
jar -cf libtensorflow-arm64.jar -C . org/

# Verify build
print_status "Verifying build..."
if [ -f "libtensorflow-arm64.jar" ] && [ -f "libtensorflow_jni.so" ] && [ -f "libtensorflow_framework.so" ]; then
    print_status "Build completed successfully!"
    echo
    echo "Built artifacts:"
    ls -lah libtensorflow-arm64.jar libtensorflow_jni.so libtensorflow_framework.so
    echo
    echo "File checksums:"
    sha256sum libtensorflow-arm64.jar libtensorflow_jni.so libtensorflow_framework.so
    echo
    echo "Usage:"
    echo "  java -cp .:libtensorflow-arm64.jar YourTensorFlowApp"
    echo
    echo "The libtensorflow-arm64.jar contains all necessary native libraries."
else
    echo "Error: Build failed - some artifacts are missing"
    exit 1
fi

print_status "TensorFlow JNI compilation completed successfully!"
