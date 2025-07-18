#!/bin/bash

# Script to install JDK and required tools for JNI development on Ubuntu
# This script is intended for ARM64 Ubuntu systems

# Exit on error
set -e

echo "Installing OpenJDK and development tools for JNI..."

# Update package lists
sudo apt-get update

# Install OpenJDK
sudo apt-get install -y openjdk-21-jdk

# Install build tools
sudo apt-get install -y build-essential

# Verify installations
echo "Verifying installations..."

# Check Java version
java -version
javac -version

# Check GCC version
gcc --version

echo "Installation complete. Your system is now ready for JNI development."

# Print JNI include paths
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
echo "JNI include paths:"
echo "  $JAVA_HOME/include"
echo "  $JAVA_HOME/include/linux"

echo ""
echo "To compile JNI code, use:"
echo "gcc -shared -fPIC -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -o libname.so your_native_code.c"
