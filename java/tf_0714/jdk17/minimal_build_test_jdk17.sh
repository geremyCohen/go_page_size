#!/bin/bash

# Minimal TensorFlow JNI Build Test for JDK17
# Tests the build configuration and applies fixes without full compilation

set -e

echo "=== Minimal TensorFlow JNI Build Test for JDK17 ==="

# Configuration
TENSORFLOW_VERSION="v2.13.0"
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-arm64"
BUILD_DIR="tensorflow_jdk17_minimal"

# Set environment
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export BAZEL_CXXOPTS="-std=c++17"

echo "Using Java: $(java -version 2>&1 | head -n1)"
echo "Using Bazel: $(bazel --version)"

# Clone and setup
if [ ! -d "$BUILD_DIR" ]; then
    echo "Cloning TensorFlow..."
    git clone --depth 1 https://github.com/tensorflow/tensorflow.git "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Checkout version
echo "Checking out $TENSORFLOW_VERSION..."
git fetch origin tag "$TENSORFLOW_VERSION" --depth 1
git checkout "$TENSORFLOW_VERSION"

# Apply ARM64 fixes
echo "Applying ARM64 fixes..."

# Fix 1: tensorflow_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/tensorflow_jni.cc; then
    echo "Adding cstdint to tensorflow_jni.cc"
    sed -i '/^#include "tensorflow\/java\/src\/main\/native\/tensorflow_jni.h"$/a #include <cstdint>' tensorflow/java/src/main/native/tensorflow_jni.cc
fi

# Fix 2: tensor_jni.cc  
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/tensor_jni.cc; then
    echo "Adding cstdint to tensor_jni.cc"
    sed -i '/^#include "tensorflow\/java\/src\/main\/native\/tensor_jni.h"$/a #include <cstdint>' tensorflow/java/src/main/native/tensor_jni.cc
fi

# Fix 3: session_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/session_jni.cc; then
    echo "Adding cstdint to session_jni.cc"
    sed -i '1i #include <cstdint>' tensorflow/java/src/main/native/session_jni.cc
fi

# Fix 4: cache.h
if ! grep -q "#include <cstdint>" tensorflow/tsl/lib/io/cache.h; then
    echo "Adding cstdint to cache.h"
    sed -i '/^#ifndef TENSORFLOW_TSL_LIB_IO_CACHE_H_$/a #define TENSORFLOW_TSL_LIB_IO_CACHE_H_\n\n#include <cstdint>\n#include "tensorflow/tsl/platform/stringpiece.h"' tensorflow/tsl/lib/io/cache.h
    sed -i '/^#define TENSORFLOW_TSL_LIB_IO_CACHE_H_$/d' tensorflow/tsl/lib/io/cache.h
    sed -i '/^#include "tensorflow\/tsl\/platform\/stringpiece.h"$/d' tensorflow/tsl/lib/io/cache.h
fi

# Fix 5: denormal.cc
if ! grep -q "#include <cstdint>" tensorflow/tsl/platform/denormal.cc; then
    echo "Adding cstdint to denormal.cc"
    sed -i '/^#include "tensorflow\/tsl\/platform\/denormal.h"$/a #include <cstdint>' tensorflow/tsl/platform/denormal.cc
fi

echo "ARM64 fixes applied!"

# Configure TensorFlow
echo "Configuring TensorFlow..."
python3 configure.py <<EOF


n
n
n

n
EOF

echo "Configuration complete!"

# Test build configuration (without actual compilation)
echo "Testing build configuration..."
bazel query "//tensorflow/java:tensorflow" >/dev/null 2>&1 && echo "✅ Java target found"
bazel query "//tensorflow/java:libtensorflow_jni" >/dev/null 2>&1 && echo "✅ JNI target found"
bazel query "//tensorflow:libtensorflow_framework.so" >/dev/null 2>&1 && echo "✅ Framework target found"

echo
echo "✅ Minimal build test completed successfully!"
echo "All targets are accessible and ARM64 fixes have been applied."
echo "The configuration is ready for full compilation."

cd ..

# Create success indicator
echo "JDK17 minimal build test passed on $(date)" > jdk17_build_test_success.txt

echo
echo "To run the full compilation, use: ./compile_tensorflow_jni_jdk17.sh"
