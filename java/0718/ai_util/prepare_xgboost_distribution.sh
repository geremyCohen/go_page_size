#!/bin/bash

# Script to prepare XGBoost artifacts for distribution
# This script copies the necessary files from the build directory to the script directory

set -e  # Exit on error

echo "Preparing XGBoost artifacts for distribution..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build"

# Check if the build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found: $BUILD_DIR"
    exit 1
fi

# Check if the required artifacts exist
if [ ! -f "$BUILD_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ] || [ ! -f "$BUILD_DIR/libxgboost.so" ]; then
    echo "Error: Required XGBoost artifacts not found in the build directory"
    echo "Make sure to build XGBoost first"
    exit 1
fi

# Copy the artifacts to the script directory
echo "Copying XGBoost artifacts to: $SCRIPT_DIR"
cp "$BUILD_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" "$SCRIPT_DIR/"
cp "$BUILD_DIR/libxgboost.so" "$SCRIPT_DIR/"

# Copy libdmlc.so.0.6 if it exists
if [ -f "$BUILD_DIR/libdmlc.so.0.6" ]; then
    echo "Copying libdmlc.so.0.6"
    cp "$BUILD_DIR/libdmlc.so.0.6" "$SCRIPT_DIR/"
    
    # Create a symbolic link
    echo "Creating symbolic link: libdmlc.so.0 -> libdmlc.so.0.6"
    ln -sf libdmlc.so.0.6 "$SCRIPT_DIR/libdmlc.so.0"
elif [ -f "$BUILD_DIR/libdmlc.so.0" ]; then
    echo "Copying libdmlc.so.0"
    cp "$BUILD_DIR/libdmlc.so.0" "$SCRIPT_DIR/"
else
    echo "Warning: libdmlc.so.0 or libdmlc.so.0.6 not found in the build directory"
    echo "The application may fail to run if these libraries are not available"
fi

# Copy commons-logging if it exists
if [ -f "$BUILD_DIR/commons-logging-1.2.jar" ]; then
    echo "Copying commons-logging-1.2.jar"
    cp "$BUILD_DIR/commons-logging-1.2.jar" "$SCRIPT_DIR/"
fi

echo "Done! XGBoost artifacts are ready for distribution."
echo ""
echo "To distribute, copy the following files to the target machine:"
echo "1. $SCRIPT_DIR/run_xgboost_hello_world.sh"
echo "2. $SCRIPT_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar"
echo "3. $SCRIPT_DIR/libxgboost.so"
echo "4. $SCRIPT_DIR/libdmlc.so.0.6 (if available)"
echo "5. $SCRIPT_DIR/libdmlc.so.0 (if available)"
echo ""
