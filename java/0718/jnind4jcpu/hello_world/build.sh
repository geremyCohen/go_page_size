#!/bin/bash

# Set the paths
HELLO_WORLD_SRC=src/main/java/com/example/helloworld/HelloWorldJNI.java
JNI_JAR=../../ai_build/jnind4jcpu.jar
BUILD_DIR=build

# Create build directory if it doesn't exist
mkdir -p $BUILD_DIR

# Compile the Hello World application
echo "Compiling Hello World application..."
javac -cp $JNI_JAR:. -d $BUILD_DIR $HELLO_WORLD_SRC

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
else
    echo "Compilation failed!"
    exit 1
fi
