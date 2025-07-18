#!/bin/bash

# Exit on error
set -e

echo "Installing JDK and development tools for JNI support..."

# Update package lists
apt-get update

# Install JDK (includes JRE)
apt-get install -y openjdk-21-jdk

# Install build tools needed for compiling native code
apt-get install -y build-essential cmake maven git

# Install additional dependencies for XGBoost
apt-get install -y libgomp1 python3 python3-pip

# Verify installations
echo "Verifying installations..."
java -version
javac -version
gcc --version
cmake --version
mvn --version
git --version

echo "JNI development environment setup complete!"
echo "You can now compile Java applications with JNI support."
