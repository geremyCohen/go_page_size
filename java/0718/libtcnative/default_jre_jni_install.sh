#!/bin/bash
# default_jre_jni_install.sh
# Script to install dependencies required for JNI development on Ubuntu
# This script will install the necessary packages to compile JNI applications

set -e

echo "Installing dependencies for JNI development..."

# Update package lists
sudo apt-get update

# Install JDK (if not already installed)
if ! command -v javac &> /dev/null; then
    echo "Installing OpenJDK..."
    sudo apt-get install -y openjdk-21-jdk
fi

# Install build tools
sudo apt-get install -y build-essential autoconf automake libtool pkg-config

# Install APR development libraries
sudo apt-get install -y libapr1-dev

# Install OpenSSL development libraries
sudo apt-get install -y libssl-dev

# Install Ant for building Java components
sudo apt-get install -y ant

# Set JAVA_HOME if not already set
if [ -z "$JAVA_HOME" ]; then
    # Try to find Java installation
    if [ -d "/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)" ]; then
        export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)"
    elif [ -d "/usr/lib/jvm/default-java" ]; then
        export JAVA_HOME="/usr/lib/jvm/default-java"
    else
        echo "Could not determine JAVA_HOME automatically."
        echo "Please set JAVA_HOME manually to your JDK installation directory."
        exit 1
    fi
    
    echo "Setting JAVA_HOME to $JAVA_HOME"
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
fi

echo "JNI development environment setup complete!"
echo "You can now compile JNI applications with the following tools:"
echo "- Java compiler: $(which javac)"
echo "- C compiler: $(which gcc)"
echo "- JAVA_HOME: $JAVA_HOME"
