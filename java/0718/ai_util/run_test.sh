#!/bin/bash

# Exit on error
set -e

# Compile the test
echo "Compiling test..."
javac -cp ../ai_build/lib/ucrypto.jar UCryptoTest.java

# Run the test
echo "Running test..."
java -Djava.library.path=../ai_build/lib -cp .:../ai_build/lib/ucrypto.jar UCryptoTest
