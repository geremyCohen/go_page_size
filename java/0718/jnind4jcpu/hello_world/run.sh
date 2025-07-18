#!/bin/bash

# Set the paths
JNI_JAR=../../ai_build/jnind4jcpu.jar
BUILD_DIR=build
LIB_DIR=../../ai_build/lib

# Run the Hello World application
echo "Running Hello World application..."
java -cp $BUILD_DIR:$JNI_JAR com.example.helloworld.HelloWorldJNI
