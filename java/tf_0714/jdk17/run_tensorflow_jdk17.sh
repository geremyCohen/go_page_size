#!/bin/bash

# TensorFlow Java Runner Script for ARM64 with JDK17
# Usage: ./run_tensorflow_jdk17.sh YourJavaClass [additional_args]

if [ $# -eq 0 ]; then
    echo "Usage: $0 <JavaClassName> [additional_args]"
    echo "Example: $0 TestTensorFlowJdk17"
    exit 1
fi

JAVA_CLASS=$1
shift

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TENSORFLOW_JAR="$SCRIPT_DIR/libtensorflow-arm64-jdk17.jar"

# Check if required files exist
if [ ! -f "$TENSORFLOW_JAR" ]; then
    echo "Error: libtensorflow-arm64-jdk17.jar not found in $SCRIPT_DIR"
    exit 1
fi

# Set Java to use JDK17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
JAVA_CMD="$JAVA_HOME/bin/java"

# Check if Java class file exists
if [ ! -f "$JAVA_CLASS.class" ]; then
    echo "Java class file $JAVA_CLASS.class not found. Attempting to compile..."
    if [ -f "$JAVA_CLASS.java" ]; then
        echo "Compiling $JAVA_CLASS.java with JDK17..."
        $JAVA_HOME/bin/javac -cp "$TENSORFLOW_JAR" "$JAVA_CLASS.java"
        if [ $? -ne 0 ]; then
            echo "Compilation failed!"
            exit 1
        fi
    else
        echo "Error: Neither $JAVA_CLASS.class nor $JAVA_CLASS.java found"
        exit 1
    fi
fi

echo "Running $JAVA_CLASS with TensorFlow JNI on ARM64 using JDK17..."
echo "TensorFlow JAR: $TENSORFLOW_JAR"
echo "Java Home: $JAVA_HOME"
echo ""

# Run the Java application with JDK17
$JAVA_CMD \
    -cp ".:$TENSORFLOW_JAR" \
    "$JAVA_CLASS" \
    "$@"
