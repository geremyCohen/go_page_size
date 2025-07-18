#!/bin/bash

# Set the paths
BUILD_DIR=ai_build
LIB_DIR=$BUILD_DIR/lib
JAR_FILE=$BUILD_DIR/jnind4jcpu.jar

# Run the Java application with the native library
java -Djava.library.path=$LIB_DIR -cp $JAR_FILE com.example.jni.CPUInfo
