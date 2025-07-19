#!/bin/bash

# Script to compile XGBoost with JNI support for JDK 17
# For ARM64 architecture

set -e  # Exit on error

echo "Compiling XGBoost with JNI support for JDK 17..."

# Create directories
WORK_DIR=$(pwd)
BUILD_DIR="$WORK_DIR/build"
ARTIFACTS_DIR="$WORK_DIR/artifacts"

mkdir -p "$BUILD_DIR"
mkdir -p "$ARTIFACTS_DIR"

# Clone XGBoost repository if it doesn't exist
if [ ! -d "$BUILD_DIR/xgboost" ]; then
    echo "Cloning XGBoost repository..."
    cd "$BUILD_DIR"
    git clone --recursive https://github.com/dmlc/xgboost.git
fi

# Build the C++ library
echo "Building XGBoost C++ library..."
cd "$BUILD_DIR/xgboost"
mkdir -p build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DUSE_CUDA=OFF -DBUILD_WITH_SHARED_NCCL=OFF
make -j4

# Set JAVA_HOME to JDK 17
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "Using JAVA_HOME: $JAVA_HOME"

# Build the Java package with JDK 17
echo "Building XGBoost Java package with JDK 17..."
cd "$BUILD_DIR/xgboost/jvm-packages"

# Modify the pom.xml to use Java 17 instead of Java 8
echo "Updating pom.xml to use Java 17..."
sed -i 's/<maven.compiler.source>1.8<\/maven.compiler.source>/<maven.compiler.source>17<\/maven.compiler.source>/g' pom.xml
sed -i 's/<maven.compiler.target>1.8<\/maven.compiler.target>/<maven.compiler.target>17<\/maven.compiler.target>/g' pom.xml

# Build the Java package
mvn clean package -DskipTests

# Copy the artifacts
echo "Copying artifacts..."
cp "$BUILD_DIR/xgboost/lib/libxgboost.so" "$ARTIFACTS_DIR/"
cp "$BUILD_DIR/xgboost/build/dmlc-core/libdmlc.so.0.6" "$ARTIFACTS_DIR/"
ln -sf "$ARTIFACTS_DIR/libdmlc.so.0.6" "$ARTIFACTS_DIR/libdmlc.so.0"
cp "$BUILD_DIR/xgboost/jvm-packages/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" "$ARTIFACTS_DIR/"

echo "Compilation complete! Artifacts are available in $ARTIFACTS_DIR"
echo "- libxgboost.so: Native XGBoost library"
echo "- libdmlc.so.0.6: Dependency of libxgboost.so"
echo "- libdmlc.so.0: Symlink to libdmlc.so.0.6"
echo "- xgboost4j_2.12-3.1.0-SNAPSHOT.jar: Java XGBoost library"
