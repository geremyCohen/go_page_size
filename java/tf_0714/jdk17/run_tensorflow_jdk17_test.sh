#!/bin/bash

# TensorFlow Java Test Runner Script for ARM64 with JDK17

if [ $# -eq 0 ]; then
    echo "Usage: $0 <JavaClassName> [additional_args]"
    echo "Example: $0 TestTensorFlowJdk17"
    exit 1
fi

JAVA_CLASS=$1
shift

# Set Java to use JDK17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
JAVA_CMD="$JAVA_HOME/bin/java"

echo "Running $JAVA_CLASS with JDK17 on ARM64..."
echo "Java Home: $JAVA_HOME"
echo ""

# Run the Java application with JDK17
$JAVA_CMD "$JAVA_CLASS" "$@"
