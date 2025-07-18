#!/bin/bash

# Set the paths
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
BUILD_DIR=ai_build
SRC_DIR=src/main/java
NATIVE_DIR=src/main/native
PACKAGE_PATH=com/example/jni
CLASS_NAME=CPUInfo

# Create build directory if it doesn't exist
mkdir -p $BUILD_DIR/$PACKAGE_PATH
mkdir -p $NATIVE_DIR/$PACKAGE_PATH

# Compile the Java class
javac -d $BUILD_DIR $SRC_DIR/$PACKAGE_PATH/$CLASS_NAME.java

# Generate the JNI header file
javac -h $NATIVE_DIR -d $BUILD_DIR $SRC_DIR/$PACKAGE_PATH/$CLASS_NAME.java

echo "JNI header file generated at $NATIVE_DIR/com_example_jni_$CLASS_NAME.h"
