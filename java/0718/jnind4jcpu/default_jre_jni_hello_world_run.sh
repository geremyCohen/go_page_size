#!/bin/bash

# Script to compile and run the JNI Hello World application on another machine
# This script assumes that default_jre_jni_install.sh has been run

# Exit on error
set -e

# Set the paths
PROJECT_DIR="$PWD/jnind4jcpu"
HELLO_WORLD_DIR="$PROJECT_DIR/hello_world"
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

echo "Compiling and running JNI Hello World application..."

# Check if the project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory $PROJECT_DIR does not exist."
    echo "Please make sure you are in the correct directory."
    exit 1
fi

# Navigate to the Hello World directory
cd "$HELLO_WORLD_DIR"

# Clean any previous build
echo "Cleaning previous build..."
make clean

# Build the Hello World application
echo "Building Hello World application..."
make

# Run the Hello World application
echo "Running Hello World application..."
make run

echo "JNI Hello World application completed successfully."
