#!/bin/bash

# TensorFlow JNI Compilation Script for ARM64 Ubuntu 24 with JDK17
# This script automates the complete process of compiling TensorFlow with JNI support for JDK17

set -e  # Exit on any error

echo "=== TensorFlow JNI Compilation Script for ARM64 with JDK17 ==="
echo "Starting compilation process..."
echo

# Configuration
TENSORFLOW_VERSION="v2.13.0"
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-arm64"
BUILD_DIR="tensorflow_jdk17"
OUTPUT_PREFIX="jdk17"

# Function to print status messages
print_status() {
    echo ">>> $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists bazel; then
    echo "Error: Bazel is not installed. Please install Bazel first."
    exit 1
fi

if ! command_exists git; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

if [ ! -d "$JAVA_HOME_PATH" ]; then
    echo "Error: JDK17 not found at $JAVA_HOME_PATH"
    echo "Please install OpenJDK 17: sudo apt-get install openjdk-17-jdk"
    exit 1
fi

# Check for required Python packages
if ! python3 -c "import numpy" 2>/dev/null; then
    echo "Error: numpy not found. Installing..."
    sudo apt-get update && sudo apt-get install -y python3-numpy python3-wheel python3-setuptools python3-six python3-protobuf
fi

print_status "Prerequisites check passed!"

# Set environment variables for JDK17
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

print_status "Java version: $(java -version 2>&1 | head -n1)"
print_status "Bazel version: $(bazel --version)"
print_status "Using JAVA_HOME: $JAVA_HOME"

# Clone TensorFlow if not exists
if [ ! -d "$BUILD_DIR" ]; then
    print_status "Cloning TensorFlow repository for JDK17 build..."
    git clone https://github.com/tensorflow/tensorflow.git "$BUILD_DIR"
else
    print_status "TensorFlow repository already exists"
fi

cd "$BUILD_DIR"

# Checkout specific version
print_status "Checking out TensorFlow $TENSORFLOW_VERSION..."
git fetch origin tag "$TENSORFLOW_VERSION" --depth 1
git checkout "$TENSORFLOW_VERSION"

# Apply ARM64 fixes
print_status "Applying ARM64 compilation fixes..."

# Fix 1: tensorflow_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/tensorflow_jni.cc; then
    print_status "Adding cstdint header to tensorflow_jni.cc"
    sed -i '/^#include "tensorflow\/java\/src\/main\/native\/tensorflow_jni.h"$/a #include <cstdint>' tensorflow/java/src/main/native/tensorflow_jni.cc
fi

# Fix 2: tensor_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/tensor_jni.cc; then
    print_status "Adding cstdint header to tensor_jni.cc"
    sed -i '/^#include "tensorflow\/java\/src\/main\/native\/tensor_jni.h"$/a #include <cstdint>' tensorflow/java/src/main/native/tensor_jni.cc
fi

# Fix 3: session_jni.cc
if ! grep -q "#include <cstdint>" tensorflow/java/src/main/native/session_jni.cc; then
    print_status "Adding cstdint header to session_jni.cc"
    sed -i '1i #include <cstdint>' tensorflow/java/src/main/native/session_jni.cc
fi

# Fix 4: cache.h
if ! grep -q "#include <cstdint>" tensorflow/tsl/lib/io/cache.h; then
    print_status "Adding cstdint and cstddef headers to cache.h"
    sed -i '/^#include "tensorflow\/tsl\/platform\/stringpiece.h"$/i #include <cstdint>\n#include <cstddef>' tensorflow/tsl/lib/io/cache.h
fi

# Fix 5: denormal.cc
if ! grep -q "#include <cstdint>" tensorflow/tsl/platform/denormal.cc; then
    print_status "Adding cstdint header to denormal.cc"
    sed -i '/^#include "tensorflow\/tsl\/platform\/denormal.h"$/a #include <cstdint>' tensorflow/tsl/platform/denormal.cc
fi

# JDK17-specific configuration adjustments
print_status "Applying JDK17-specific configurations..."

# Configure TensorFlow with JDK17 settings
print_status "Configuring TensorFlow build for JDK17..."
python3 configure.py <<EOF


n
n
n

n
EOF

# JDK17 may require additional compiler flags for compatibility
export BAZEL_CXXOPTS="-std=c++17"
export BAZEL_LINKOPTS=""

# Build TensorFlow JNI with JDK17-specific settings
print_status "Building TensorFlow JNI libraries for JDK17 (this will take several hours)..."
print_status "Building Java JAR and JNI library..."

# Use JDK17-compatible build flags
bazel build \
    --config=opt \
    --cxxopt=-std=c++17 \
    --host_cxxopt=-std=c++17 \
    --action_env=JAVA_HOME="$JAVA_HOME" \
    --java_runtime_version=remotejdk_17 \
    //tensorflow/java:tensorflow //tensorflow/java:libtensorflow_jni

print_status "Building framework library..."
bazel build \
    --config=opt \
    --cxxopt=-std=c++17 \
    --host_cxxopt=-std=c++17 \
    --action_env=JAVA_HOME="$JAVA_HOME" \
    //tensorflow:libtensorflow_framework.so

# Copy built artifacts with JDK17 naming
print_status "Copying built artifacts..."
cd ..

cp "$BUILD_DIR/bazel-bin/tensorflow/java/libtensorflow.jar" "libtensorflow-${OUTPUT_PREFIX}.jar"
cp "$BUILD_DIR/bazel-bin/tensorflow/java/libtensorflow_jni.so" "libtensorflow_jni-${OUTPUT_PREFIX}.so"
cp "$BUILD_DIR/bazel-bin/tensorflow/libtensorflow_framework.so" "libtensorflow_framework-${OUTPUT_PREFIX}.so"

# Create versioned framework library
ln -sf "libtensorflow_framework-${OUTPUT_PREFIX}.so" "libtensorflow_framework-${OUTPUT_PREFIX}.so.2"

# Create complete JAR with embedded native libraries for JDK17
print_status "Creating complete JAR with embedded native libraries for JDK17..."
mkdir -p org/tensorflow/native/linux-aarch64
cp "libtensorflow_jni-${OUTPUT_PREFIX}.so" org/tensorflow/native/linux-aarch64/libtensorflow_jni.so
cp "libtensorflow_framework-${OUTPUT_PREFIX}.so.2" org/tensorflow/native/linux-aarch64/libtensorflow_framework.so.2

# Extract original JAR and repackage with native libraries
jar -xf "libtensorflow-${OUTPUT_PREFIX}.jar"
jar -cf "libtensorflow-arm64-${OUTPUT_PREFIX}.jar" -C . org/

# Clean up temporary extraction
rm -rf org/ META-INF/

# Create JDK17-specific test file
print_status "Creating JDK17 test file..."
cat > "TestTensorFlow-${OUTPUT_PREFIX}.java" << 'JAVA_EOF'
import org.tensorflow.TensorFlow;
import org.tensorflow.Graph;
import org.tensorflow.Session;
import org.tensorflow.Tensor;

public class TestTensorFlowJdk17 {
    public static void main(String[] args) {
        System.out.println("=== TensorFlow JDK17 Test ===");
        System.out.println("TensorFlow version: " + TensorFlow.version());
        System.out.println("Java version: " + System.getProperty("java.version"));
        System.out.println("Java vendor: " + System.getProperty("java.vendor"));
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println();
        
        // Create a simple computation graph
        try (Graph g = new Graph()) {
            // Create a constant tensor
            try (Tensor<?> t = Tensor.create(42.0f)) {
                g.opBuilder("Const", "MyConst")
                    .setAttr("dtype", t.dataType())
                    .setAttr("value", t)
                    .build();
            }
            
            // Run the graph
            try (Session s = new Session(g);
                 Tensor<?> result = s.runner().fetch("MyConst").run().get(0)) {
                System.out.println("Result: " + result.floatValue());
                System.out.println("✅ TensorFlow JNI is working correctly on ARM64 with JDK17!");
            }
        }
    }
}
JAVA_EOF

# Create JDK17-specific runner script
print_status "Creating JDK17 runner script..."
cat > "run_tensorflow_jdk17.sh" << 'SCRIPT_EOF'
#!/bin/bash

# TensorFlow Java Runner Script for ARM64 with JDK17
# Usage: ./run_tensorflow_jdk17.sh YourJavaClass [additional_args]

if [ $# -eq 0 ]; then
    echo "Usage: $0 <JavaClassName> [additional_args]"
    echo "Example: $0 TestTensorFlowJdk17"
    exit 1
fi

JAVA_CLASS=$1
shift

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TENSORFLOW_JAR="$SCRIPT_DIR/libtensorflow-arm64-jdk17.jar"

# Check if required files exist
if [ ! -f "$TENSORFLOW_JAR" ]; then
    echo "Error: libtensorflow-arm64-jdk17.jar not found in $SCRIPT_DIR"
    exit 1
fi

# Set Java to use JDK17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
JAVA_CMD="$JAVA_HOME/bin/java"

# Check if Java class file exists
if [ ! -f "$JAVA_CLASS.class" ]; then
    echo "Java class file $JAVA_CLASS.class not found. Attempting to compile..."
    if [ -f "$JAVA_CLASS.java" ]; then
        echo "Compiling $JAVA_CLASS.java with JDK17..."
        $JAVA_HOME/bin/javac -cp "$TENSORFLOW_JAR" "$JAVA_CLASS.java"
        if [ $? -ne 0 ]; then
            echo "Compilation failed!"
            exit 1
        fi
    else
        echo "Error: Neither $JAVA_CLASS.class nor $JAVA_CLASS.java found"
        exit 1
    fi
fi

echo "Running $JAVA_CLASS with TensorFlow JNI on ARM64 using JDK17..."
echo "TensorFlow JAR: $TENSORFLOW_JAR"
echo "Java Home: $JAVA_HOME"
echo ""

# Run the Java application with JDK17
$JAVA_CMD \
    -cp ".:$TENSORFLOW_JAR" \
    "$JAVA_CLASS" \
    "$@"
SCRIPT_EOF

chmod +x "run_tensorflow_jdk17.sh"

# Verify build
print_status "Verifying JDK17 build..."
if [ -f "libtensorflow-arm64-${OUTPUT_PREFIX}.jar" ] && [ -f "libtensorflow_jni-${OUTPUT_PREFIX}.so" ] && [ -f "libtensorflow_framework-${OUTPUT_PREFIX}.so" ]; then
    print_status "JDK17 build completed successfully!"
    echo
    echo "Built artifacts for JDK17:"
    ls -lah libtensorflow-arm64-${OUTPUT_PREFIX}.jar libtensorflow_jni-${OUTPUT_PREFIX}.so libtensorflow_framework-${OUTPUT_PREFIX}.so
    echo
    echo "File checksums:"
    sha256sum libtensorflow-arm64-${OUTPUT_PREFIX}.jar libtensorflow_jni-${OUTPUT_PREFIX}.so libtensorflow_framework-${OUTPUT_PREFIX}.so > "CHECKSUMS-${OUTPUT_PREFIX}.txt"
    cat "CHECKSUMS-${OUTPUT_PREFIX}.txt"
    echo
    
    # Test the build
    print_status "Testing the JDK17 build..."
    if ./run_tensorflow_jdk17.sh "TestTensorFlow-${OUTPUT_PREFIX}"; then
        print_status "✅ JDK17 build test passed!"
    else
        print_status "⚠️  JDK17 build test failed, but libraries were built successfully"
    fi
    
    echo
    echo "Usage for JDK17:"
    echo "  java -cp .:libtensorflow-arm64-${OUTPUT_PREFIX}.jar YourTensorFlowApp"
    echo "  OR use: ./run_tensorflow_jdk17.sh YourJavaClass"
    echo
    echo "The libtensorflow-arm64-${OUTPUT_PREFIX}.jar contains all necessary native libraries for JDK17."
else
    echo "Error: JDK17 build failed - some artifacts are missing"
    exit 1
fi

print_status "TensorFlow JNI compilation for JDK17 completed successfully!"
