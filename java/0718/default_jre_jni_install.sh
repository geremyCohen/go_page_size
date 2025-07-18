#!/bin/bash

# Exit on error
set -e

echo "Installing JDK and JNI development tools for ARM64 Ubuntu..."

# Update package lists
sudo apt-get update

# Install OpenJDK
sudo apt-get install -y openjdk-21-jdk

# Install build tools
sudo apt-get install -y build-essential

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
echo "JAVA_HOME set to $JAVA_HOME"

# Add JAVA_HOME to .bashrc if it's not already there
if ! grep -q "export JAVA_HOME=" ~/.bashrc; then
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
    echo "Added JAVA_HOME to .bashrc"
fi

# Verify installation
echo "Verifying installation..."
java -version
javac -version
gcc --version

echo "JNI development environment setup complete!"
