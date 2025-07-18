#!/bin/bash
set -e

# Build the Hello World application
echo "Building XGBoost Hello World application..."
mvn clean package

# Run the Hello World application
echo "Running XGBoost Hello World application..."
java -cp target/xgboost-hello-world-1.0-SNAPSHOT-jar-with-dependencies.jar XGBoostHelloWorld
