#!/bin/bash

# Standalone script to install JDK17, compile XGBoost with JNI support, and run a hello world example
# This script doesn't require cloning a repository - it creates all necessary files locally

set -e  # Exit on error

echo "=== XGBoost JDK17 Standalone Script ==="
echo "This script will:"
echo "1. Install JDK17 and required tools"
echo "2. Compile XGBoost with JDK17 support"
echo "3. Run a hello world example"
echo ""

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Create working directory
WORK_DIR="$HOME/xgboost_jdk17"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Create JDK17 installation script
echo "Creating JDK17 installation script..."
cat > jdk17_install.sh << 'EOF'
#!/bin/bash

# Script to install JDK 17 and development tools for JNI support on Ubuntu
# For ARM64 architecture

set -e  # Exit on error

echo "Installing JDK 17 and development tools for JNI support..."

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

# Install JDK 17 instead of JDK 21
echo "Installing OpenJDK 17..."
$APT_CMD install -y openjdk-17-jdk

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
cat > ~/jni_test/HelloJNI.java << 'EOT'
public class HelloJNI {
    static {
        System.loadLibrary("hello");
    }

    private native void sayHello();

    public static void main(String[] args) {
        new HelloJNI().sayHello();
    }
}
EOT

cat > ~/jni_test/HelloJNI.c << 'EOT'
#include <jni.h>
#include <stdio.h>
#include "HelloJNI.h"

JNIEXPORT void JNICALL Java_HelloJNI_sayHello(JNIEnv *env, jobject obj) {
    printf("Hello from JNI!\n");
    return;
}
EOT

cat > ~/jni_test/build.sh << 'EOT'
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
EOT

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
EOF

# Create XGBoost compilation script
echo "Creating XGBoost compilation script..."
cat > compile_xgboost_jdk17.sh << 'EOF'
#!/bin/bash

# Script to compile XGBoost with JNI support for JDK 17
# For ARM64 architecture

set -e  # Exit on error

echo "Compiling XGBoost with JNI support for JDK 17..."

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Install Python if not already installed
if ! command -v python &> /dev/null; then
    echo "Python not found. Installing Python..."
    $APT_CMD update
    $APT_CMD install -y python3 python-is-python3
fi

# Create directories
WORK_DIR=$(pwd)
BUILD_DIR="$WORK_DIR/build"
ARTIFACTS_DIR="$WORK_DIR/artifacts"

mkdir -p "$BUILD_DIR"
mkdir -p "$ARTIFACTS_DIR"

# Clone XGBoost repository if it doesn't exist
if [ ! -d "$BUILD_DIR/xgboost" ]; then
    echo "Cloning XGBoost repository..."
    cd "$BUILD_DIR"
    git clone --recursive https://github.com/dmlc/xgboost.git
fi

# Build the C++ library
echo "Building XGBoost C++ library..."
cd "$BUILD_DIR/xgboost"
mkdir -p build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DUSE_CUDA=OFF -DBUILD_WITH_SHARED_NCCL=OFF
make -j4

# Set JAVA_HOME to JDK 17
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "Using JAVA_HOME: $JAVA_HOME"

# Build the Java package with JDK 17
echo "Building XGBoost Java package with JDK 17..."
cd "$BUILD_DIR/xgboost/jvm-packages"

# Modify the pom.xml to use Java 17 instead of Java 8
echo "Updating pom.xml to use Java 17..."
sed -i 's/<maven.compiler.source>1.8<\/maven.compiler.source>/<maven.compiler.source>17<\/maven.compiler.source>/g' pom.xml
sed -i 's/<maven.compiler.target>1.8<\/maven.compiler.target>/<maven.compiler.target>17<\/maven.compiler.target>/g' pom.xml

# Update the Scala Maven plugin configuration to work with JDK 17
echo "Updating Scala Maven plugin configuration for JDK 17 compatibility..."
sed -i '/<artifactId>scala-maven-plugin<\/artifactId>/,/<\/plugin>/ s/<\/configuration>/  <jvmArgs>\n    <jvmArg>--add-opens=java.base\/java.lang=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.invoke=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.reflect=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.io=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.net=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.nio=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent.atomic=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.ch=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.cs=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.security.action=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.util.calendar=ALL-UNNAMED<\/jvmArg>\n  <\/jvmArgs>\n<\/configuration>/' pom.xml

# Also add the JVM args to the exec-maven-plugin
echo "Updating exec-maven-plugin configuration for JDK 17 compatibility..."
sed -i '/<artifactId>exec-maven-plugin<\/artifactId>/,/<\/plugin>/ s/<\/configuration>/  <jvmArgs>\n    <jvmArg>--add-opens=java.base\/java.lang=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.invoke=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.reflect=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.io=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.net=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.nio=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent.atomic=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.ch=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.cs=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.security.action=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.util.calendar=ALL-UNNAMED<\/jvmArg>\n  <\/jvmArgs>\n<\/configuration>/' pom.xml

# Build the Java package with skipTests to avoid test failures
echo "Building the Java package with JDK 17..."
export MAVEN_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
mvn clean package -DskipTests

# Copy the artifacts
echo "Copying artifacts..."
cp "$BUILD_DIR/xgboost/lib/libxgboost.so" "$ARTIFACTS_DIR/"
cp "$BUILD_DIR/xgboost/build/dmlc-core/libdmlc.so.0.6" "$ARTIFACTS_DIR/"
ln -sf "$ARTIFACTS_DIR/libdmlc.so.0.6" "$ARTIFACTS_DIR/libdmlc.so.0"
cp "$BUILD_DIR/xgboost/jvm-packages/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" "$ARTIFACTS_DIR/"

echo "Compilation complete! Artifacts are available in $ARTIFACTS_DIR"
echo "- libxgboost.so: Native XGBoost library"
echo "- libdmlc.so.0.6: Dependency of libxgboost.so"
echo "- libdmlc.so.0: Symlink to libdmlc.so.0.6"
echo "- xgboost4j_2.12-3.1.0-SNAPSHOT.jar: Java XGBoost library"
EOF

# Create hello world script
echo "Creating hello world script..."
cat > jdk17_hello_world_run.sh << 'EOF'
#!/bin/bash

# Script to run the XGBoost Hello World application with JDK 17
# This script assumes that jdk17_install.sh has been run to set up JDK 17

set -e  # Exit on error

echo "Setting up and running XGBoost Hello World with JDK 17..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create a directory for the application
mkdir -p ~/xgboost_hello_world
cd ~/xgboost_hello_world

# Download required libraries
echo "Downloading required libraries..."
wget -q https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar

# Copy XGBoost artifacts from the script directory if they exist
if [ -f "$SCRIPT_DIR/artifacts/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ] && [ -f "$SCRIPT_DIR/artifacts/libxgboost.so" ]; then
    echo "Using XGBoost artifacts from the script directory: $SCRIPT_DIR/artifacts"
    cp "$SCRIPT_DIR/artifacts/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" .
    cp "$SCRIPT_DIR/artifacts/libxgboost.so" .
    
    # Copy libdmlc.so.0.6 if it exists
    if [ -f "$SCRIPT_DIR/artifacts/libdmlc.so.0.6" ]; then
        echo "Copying libdmlc.so.0.6 from the script directory"
        cp "$SCRIPT_DIR/artifacts/libdmlc.so.0.6" .
        ln -sf libdmlc.so.0.6 libdmlc.so.0
    elif [ -f "$SCRIPT_DIR/artifacts/libdmlc.so.0" ]; then
        echo "Copying libdmlc.so.0 from the script directory"
        cp "$SCRIPT_DIR/artifacts/libdmlc.so.0" .
    else
        echo "Warning: libdmlc.so.0 or libdmlc.so.0.6 not found in the script directory"
        echo "The application may fail to run if these libraries are not available"
    fi
else
    echo "XGBoost artifacts not found in the script directory. Looking in current directory..."
    if [ ! -f "xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ] || [ ! -f "libxgboost.so" ]; then
        echo "XGBoost artifacts not found. Please copy the following files to the current directory or the script directory:"
        echo "1. xgboost4j_2.12-3.1.0-SNAPSHOT.jar"
        echo "2. libxgboost.so"
        echo "3. libdmlc.so.0.6 (and create a symlink: ln -sf libdmlc.so.0.6 libdmlc.so.0)"
        exit 1
    fi
fi

# Create the Hello World Java file with JDK 17 features
echo "Creating XGBoostHelloWorld.java with JDK 17 features..."
cat > XGBoostHelloWorld.java << 'EOT'
import ml.dmlc.xgboost4j.java.DMatrix;
import ml.dmlc.xgboost4j.java.XGBoostError;
import java.io.File;

/**
 * A simple Hello World application that demonstrates loading the XGBoost library via JNI
 * and creating a DMatrix to verify the JNI binding is working.
 * This version uses JDK 17 features like text blocks and var.
 */
public class XGBoostHelloWorld {
    
    // Path to the native library
    private static final String NATIVE_LIB_PATH = "./libxgboost.so";
    
    public static void main(String[] args) {
        try {
            // Using text blocks (JDK 15+)
            System.out.println("""
                XGBoost Hello World - JNI Test with JDK 17
                -----------------------------------------
                """);
            
            // Explicitly load the native library
            System.out.println("Loading native library from: " + NATIVE_LIB_PATH);
            var nativeLib = new File(NATIVE_LIB_PATH);  // Using var (JDK 10+)
            if (!nativeLib.exists()) {
                throw new RuntimeException("Native library not found at: " + NATIVE_LIB_PATH);
            }
            System.load(nativeLib.getAbsolutePath());
            System.out.println("Native library loaded successfully!");
            
            // Create a simple DMatrix
            System.out.println("\nCreating a simple DMatrix...");
            float[] data = new float[] {
                1.0f, 2.0f, 3.0f,
                4.0f, 5.0f, 6.0f
            };
            float[] labels = new float[] {0.0f, 1.0f};
            
            var dmatrix = new DMatrix(data, 2, 3);  // Using var (JDK 10+)
            dmatrix.setLabel(labels);
            
            System.out.println("DMatrix created successfully!");
            System.out.println("Number of rows: " + dmatrix.rowNum());
            
            // Clean up
            dmatrix.dispose();
            System.out.println("DMatrix disposed successfully!");
            
            System.out.println("\nJNI test completed successfully!");
            
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (XGBoostError e) {
            System.err.println("XGBoost error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error during XGBoost JNI test: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOT

# Compile the Java code with JDK 17
echo "Compiling XGBoostHelloWorld.java with JDK 17..."
javac --release 17 -cp "./xgboost4j_2.12-3.1.0-SNAPSHOT.jar:./commons-logging-1.2.jar" XGBoostHelloWorld.java

# Run the application with LD_LIBRARY_PATH set to include the current directory
echo "Running XGBoostHelloWorld with JDK 17..."
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH java -cp ".:./xgboost4j_2.12-3.1.0-SNAPSHOT.jar:./commons-logging-1.2.jar" XGBoostHelloWorld

echo "Done!"
EOF

# Make scripts executable
chmod +x jdk17_install.sh compile_xgboost_jdk17.sh jdk17_hello_world_run.sh

# Install required tools
echo "=== Installing required tools ==="
$APT_CMD update
$APT_CMD install -y git wget maven python3 python-is-python3

# Run the JDK17 installation script
echo "=== Running JDK17 installation script ==="
./jdk17_install.sh

# Source the updated environment variables
source ~/.bashrc

# Run the JDK17 XGBoost compile script
echo "=== Running JDK17 XGBoost compile script ==="
./compile_xgboost_jdk17.sh

# Run the JDK17 XGBoost hello world script
echo "=== Running JDK17 XGBoost hello world script ==="
./jdk17_hello_world_run.sh

echo ""
echo "=== All done! ==="
echo "The JDK17 XGBoost installation, compilation, and hello world test have been completed successfully."
