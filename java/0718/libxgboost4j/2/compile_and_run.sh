#!/bin/bash

# Script to compile and run the XGBoost Hello World application

set -e  # Exit on error

echo "Compiling and running XGBoost Hello World..."

# Set paths
XGBOOST_JAR="/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar"
NATIVE_LIB="/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libxgboost.so"
COMMONS_LOGGING_JAR="/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/commons-logging-1.2.jar"

# Check if the JAR files exist
if [ ! -f "$XGBOOST_JAR" ]; then
    echo "Error: XGBoost JAR file not found at $XGBOOST_JAR"
    exit 1
fi

if [ ! -f "$COMMONS_LOGGING_JAR" ]; then
    echo "Error: Commons Logging JAR file not found at $COMMONS_LOGGING_JAR"
    exit 1
fi

# Check if the native library exists
if [ ! -f "$NATIVE_LIB" ]; then
    echo "Error: XGBoost native library not found at $NATIVE_LIB"
    exit 1
fi

# Compile the Java code
echo "Compiling XGBoostHelloWorld.java..."
javac -cp "$XGBOOST_JAR:$COMMONS_LOGGING_JAR" XGBoostHelloWorld.java

# Run the application
echo "Running XGBoostHelloWorld..."
java -cp ".:$XGBOOST_JAR:$COMMONS_LOGGING_JAR" XGBoostHelloWorld

echo "Done!"
