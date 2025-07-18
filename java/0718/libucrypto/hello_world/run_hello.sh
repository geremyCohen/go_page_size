#!/bin/bash

# Exit on error
set -e

# Compile the Hello World application
echo "Compiling Hello World application..."
javac -cp ../../ai_build/lib/ucrypto.jar HelloJNI.java

# Run the Hello World application
echo "Running Hello World application..."
java -Djava.library.path=../../ai_build/lib -cp .:../../ai_build/lib/ucrypto.jar HelloJNI
