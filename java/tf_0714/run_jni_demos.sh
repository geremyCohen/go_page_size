#!/bin/bash

# TensorFlow JNI Demo Runner Script
# Runs all the JNI Hello World demonstrations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set Java to use Java 11
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
JAVAC="$JAVA_HOME/bin/javac"
JAVA="$JAVA_HOME/bin/java"

echo "=== TensorFlow JNI Demo Runner ==="
echo "Java Home: $JAVA_HOME"
echo "Working Directory: $SCRIPT_DIR"
echo

# Check if libraries exist
if [ ! -f "libtensorflow.jar" ]; then
    echo "❌ Error: libtensorflow.jar not found"
    exit 1
fi

if [ ! -f "libtensorflow_jni.so" ]; then
    echo "❌ Error: libtensorflow_jni.so not found"
    exit 1
fi

if [ ! -f "libtensorflow_framework.so" ]; then
    echo "❌ Error: libtensorflow_framework.so not found"
    exit 1
fi

echo "✅ All required libraries found"
echo

# Demo 1: Simple JNI Hello World
echo "=== Running Demo 1: Simple JNI Hello World ==="
if [ ! -f "SimpleJNIHelloWorld.class" ] || [ "SimpleJNIHelloWorld.java" -nt "SimpleJNIHelloWorld.class" ]; then
    echo "Compiling SimpleJNIHelloWorld.java..."
    $JAVAC -cp libtensorflow.jar SimpleJNIHelloWorld.java
    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed"
        exit 1
    fi
fi

echo "Running SimpleJNIHelloWorld..."
$JAVA -cp .:libtensorflow.jar SimpleJNIHelloWorld
echo
echo "Press Enter to continue to next demo..."
read

# Demo 2: Detailed JNI Demo
echo "=== Running Demo 2: Detailed JNI Demo ==="
if [ ! -f "DetailedJNIDemo.class" ] || [ "DetailedJNIDemo.java" -nt "DetailedJNIDemo.class" ]; then
    echo "Compiling DetailedJNIDemo.java..."
    $JAVAC -cp libtensorflow.jar DetailedJNIDemo.java
    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed"
        exit 1
    fi
fi

echo "Running DetailedJNIDemo..."
$JAVA -cp .:libtensorflow.jar DetailedJNIDemo
echo
echo "Press Enter to continue to next demo..."
read

# Demo 3: Full TensorFlow JNI Hello World
echo "=== Running Demo 3: Full TensorFlow JNI Hello World ==="
if [ ! -f "TensorFlowJNIHelloWorld.class" ] || [ "TensorFlowJNIHelloWorld.java" -nt "TensorFlowJNIHelloWorld.class" ]; then
    echo "Compiling TensorFlowJNIHelloWorld.java..."
    $JAVAC -cp libtensorflow.jar TensorFlowJNIHelloWorld.java
    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed"
        exit 1
    fi
fi

echo "Running TensorFlowJNIHelloWorld..."
$JAVA -cp .:libtensorflow.jar TensorFlowJNIHelloWorld
echo

echo "=== All JNI Demos Completed Successfully! ==="
echo "🎉 TensorFlow JNI libraries are working perfectly on ARM64!"
