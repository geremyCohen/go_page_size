#!/bin/bash

# Exit on error
set -e

# Check if JAVA_HOME is set
if [ -z "$JAVA_HOME" ]; then
    echo "JAVA_HOME is not set. Setting it automatically..."
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
    echo "JAVA_HOME set to $JAVA_HOME"
fi

# Create build directories
mkdir -p ../ai_build/classes
mkdir -p ../ai_build/lib

# Compile Java class and generate JNI header
echo "Compiling Java classes and generating JNI header..."
javac -h src/main/native -d ../ai_build/classes src/main/java/com/ucrypto/UCrypto.java

# Compile native library
echo "Compiling native library..."
g++ -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" -std=c++11 -Wall \
    -shared -o ../ai_build/lib/libucrypto.so src/main/native/ucrypto.cpp

# Create JAR file
echo "Creating JAR file..."
jar cf ../ai_build/lib/ucrypto.jar -C ../ai_build/classes .

echo "Build completed successfully!"
echo "Native library: ../ai_build/lib/libucrypto.so"
echo "JAR file: ../ai_build/lib/ucrypto.jar"
