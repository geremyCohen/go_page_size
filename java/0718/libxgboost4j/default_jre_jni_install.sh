#!/bin/bash

# Script to install JDK and development tools for JNI support on Ubuntu
# For ARM64 architecture

set -e  # Exit on error

echo "Installing JDK and development tools for JNI support..."

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Update package lists
$APT_CMD update

# Install JDK
echo "Installing OpenJDK..."
$APT_CMD install -y openjdk-21-jdk

# Install build tools
echo "Installing build tools..."
$APT_CMD install -y build-essential cmake git

# Install additional libraries that might be needed for JNI development
echo "Installing additional development libraries..."
$APT_CMD install -y libgfortran5 libblas-dev liblapack-dev

# Set JAVA_HOME environment variable
echo "Setting up JAVA_HOME..."
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc

# Create a simple test to verify JNI setup
echo "Creating a simple JNI test..."
mkdir -p ~/jni_test
cat > ~/jni_test/HelloJNI.java << 'EOF'
public class HelloJNI {
    static {
        System.loadLibrary("hello");
    }

    private native void sayHello();

    public static void main(String[] args) {
        new HelloJNI().sayHello();
    }
}
EOF

cat > ~/jni_test/HelloJNI.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include "HelloJNI.h"

JNIEXPORT void JNICALL Java_HelloJNI_sayHello(JNIEnv *env, jobject obj) {
    printf("Hello from JNI!\n");
    return;
}
EOF

cat > ~/jni_test/build.sh << 'EOF'
#!/bin/bash
set -e

# Compile the Java code
javac HelloJNI.java

# Generate the C header file
javac -h . HelloJNI.java

# Compile the C code into a shared library
gcc -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -shared -o libhello.so HelloJNI.c

# Run the Java program
LD_LIBRARY_PATH=. java HelloJNI
EOF

chmod +x ~/jni_test/build.sh

echo ""
echo "Installation complete!"
echo "To test your JNI setup, run: cd ~/jni_test && ./build.sh"
echo ""
echo "To compile with JNI support, make sure to:"
echo "1. Include JNI headers in your C/C++ code"
echo "2. Link against the JNI library"
echo "3. Set the correct library path when running Java applications"
echo ""
echo "For ARM64 specific development, remember to:"
echo "1. Use appropriate compiler flags for ARM architecture"
echo "2. Include <cstdint> header in C++ source files for proper integer type definitions"
echo ""
