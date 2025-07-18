#!/bin/bash

# Set the paths
HELLO_WORLD_SRC=src/main/java/com/example/helloworld/HelloWorldJNI.java
BUILD_DIR=build
NATIVE_DIR=src/main/native

# Create build and native directories if they don't exist
mkdir -p $BUILD_DIR
mkdir -p $NATIVE_DIR

# Compile the Hello World application and generate the header file
echo "Generating JNI header file..."
javac -h $NATIVE_DIR -d $BUILD_DIR $HELLO_WORLD_SRC

if [ $? -eq 0 ]; then
    echo "Header file generation successful!"
else
    echo "Header file generation failed!"
    exit 1
fi
