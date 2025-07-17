#!/bin/bash

# JavaFX JNI Test Runner Script
# Runs ExplicitJNITest with proper environment and classpath

set -e

echo "=========================================="
echo "JavaFX JNI Test Runner"
echo "ExplicitJNITest with Native Libraries"
echo "=========================================="
echo

# Function to find the most recent JavaFX build
find_javafx_build() {
    local build_dir=$(find $HOME -name "javafx_jdk17_build_*" -type d | sort | tail -1)
    if [ -n "$build_dir" ] && [ -d "$build_dir" ]; then
        echo "$build_dir"
    else
        echo ""
    fi
}

# Function to check if file exists and is readable
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ] && [ -r "$file" ]; then
        echo "✅ $description: $file"
        return 0
    else
        echo "❌ $description not found: $file"
        return 1
    fi
}

# Set up environment
echo "=== Environment Setup ==="

# Try to find and load environment file
JAVAFX_BUILD_DIR=$(find_javafx_build)
if [ -n "$JAVAFX_BUILD_DIR" ]; then
    ENV_FILE="$JAVAFX_BUILD_DIR/javafx_env.sh"
    if [ -f "$ENV_FILE" ]; then
        echo "Loading environment from: $ENV_FILE"
        source "$ENV_FILE"
    else
        echo "⚠️  Environment file not found, setting up manually..."
        export JAVAFX_BUILD_DIR="$JAVAFX_BUILD_DIR"
        export JAVAFX_SDK_DIR="$JAVAFX_BUILD_DIR/jfx/build/sdk"
        export JAVAFX_LIB_DIR="$JAVAFX_BUILD_DIR/jfx/build/sdk/lib"
        export JAVAFX_BASE_JAR="$JAVAFX_BUILD_DIR/jfx/build/sdk/lib/javafx.base.jar"
    fi
else
    echo "❌ No JavaFX build directory found!"
    echo "Please run install.sh first to build JavaFX"
    exit 1
fi

# Set up JDK17
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-arm64}
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java installation
if [ ! -d "$JAVA_HOME" ]; then
    echo "❌ JDK17 not found at: $JAVA_HOME"
    echo "Please install OpenJDK 17 or run install.sh"
    exit 1
fi

echo "✅ Java Home: $JAVA_HOME"
echo "✅ Java Version: $(java -version 2>&1 | head -1)"
echo "✅ Architecture: $(uname -m)"
echo

# Verify JavaFX build
echo "=== JavaFX Build Verification ==="
echo "Build Directory: $JAVAFX_BUILD_DIR"

# Check for required files
REQUIRED_FILES_FOUND=true

if ! check_file "$JAVAFX_BASE_JAR" "JavaFX Base JAR"; then
    REQUIRED_FILES_FOUND=false
fi

# Check for ExplicitJNITest.java
TEST_DIR="$(dirname "$0")/.."
EXPLICIT_TEST="$TEST_DIR/ExplicitJNITest.java"

if ! check_file "$EXPLICIT_TEST" "ExplicitJNITest.java"; then
    echo "Looking for ExplicitJNITest.java in current directory..."
    if [ -f "./ExplicitJNITest.java" ]; then
        EXPLICIT_TEST="./ExplicitJNITest.java"
        echo "✅ Found ExplicitJNITest.java in current directory"
    else
        echo "❌ ExplicitJNITest.java not found!"
        echo "Please ensure ExplicitJNITest.java is in the same directory as this script"
        REQUIRED_FILES_FOUND=false
    fi
fi

if [ "$REQUIRED_FILES_FOUND" = false ]; then
    echo
    echo "❌ Required files missing. Please:"
    echo "  1. Run install.sh to build JavaFX"
    echo "  2. Ensure ExplicitJNITest.java is available"
    exit 1
fi

echo

# Check native libraries
echo "=== Native Libraries Check ==="
SO_COUNT=$(find "$JAVAFX_LIB_DIR" -name "*.so" 2>/dev/null | wc -l)
if [ $SO_COUNT -gt 0 ]; then
    echo "✅ Found $SO_COUNT native libraries:"
    find "$JAVAFX_LIB_DIR" -name "*.so" | head -5 | while read lib; do
        echo "  • $(basename "$lib")"
    done
    if [ $SO_COUNT -gt 5 ]; then
        echo "  • ... and $((SO_COUNT - 5)) more"
    fi
else
    echo "⚠️  No native libraries found - using base module only"
fi

echo

# Set up classpath
echo "=== Classpath Configuration ==="

# Build classpath with available JARs
CLASSPATH="."

# Add our compiled JavaFX base JAR
if [ -f "$JAVAFX_BASE_JAR" ]; then
    CLASSPATH="$CLASSPATH:$JAVAFX_BASE_JAR"
    echo "✅ Added compiled JavaFX base: $(basename "$JAVAFX_BASE_JAR")"
fi

# Add system JavaFX JARs as fallback
SYSTEM_JARS=(
    "/usr/share/java/javafx-base.jar"
    "/usr/share/java/javafx-graphics.jar"
    "/usr/share/java/javafx-controls.jar"
)

for jar in "${SYSTEM_JARS[@]}"; do
    if [ -f "$jar" ]; then
        CLASSPATH="$CLASSPATH:$jar"
        echo "✅ Added system JAR: $(basename "$jar")"
    fi
done

echo "Classpath: $CLASSPATH"
echo

# Compile ExplicitJNITest
echo "=== Compiling ExplicitJNITest ==="
cd "$(dirname "$EXPLICIT_TEST")"

echo "Compiling ExplicitJNITest.java..."
javac -cp "$CLASSPATH" ExplicitJNITest.java

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
else
    echo "❌ Compilation failed"
    exit 1
fi

echo

# Run the test
echo "=== Running ExplicitJNITest ==="
echo "This test will:"
echo "  1. Load our compiled .so libraries explicitly"
echo "  2. Call real JavaFX native methods"
echo "  3. Demonstrate end-to-end JNI communication"
echo

# Set library path for native libraries
export LD_LIBRARY_PATH="$JAVAFX_LIB_DIR:/usr/lib/aarch64-linux-gnu/jni:$LD_LIBRARY_PATH"

echo "Starting ExplicitJNITest..."
echo "----------------------------------------"

java -cp "$CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIB_DIR:/usr/lib/aarch64-linux-gnu/jni" \
     -Dprism.order=sw \
     -Dprism.verbose=false \
     -Djava.awt.headless=true \
     ExplicitJNITest

TEST_RESULT=$?

echo "----------------------------------------"

if [ $TEST_RESULT -eq 0 ]; then
    echo
    echo "🎉 ExplicitJNITest completed successfully!"
    echo
    echo "✅ Native libraries loaded and tested"
    echo "✅ JavaFX JNI integration working"
    echo "✅ ARM64 native code execution verified"
    echo "✅ End-to-end communication: Java ↔ Native Libraries"
else
    echo
    echo "❌ ExplicitJNITest failed with exit code: $TEST_RESULT"
    echo
    echo "Troubleshooting:"
    echo "  • Check that install.sh completed successfully"
    echo "  • Verify all native libraries are present"
    echo "  • Ensure JDK17 is properly installed"
    echo "  • Check system dependencies are installed"
fi

echo

# Cleanup
echo "=== Cleanup ==="
echo "Test artifacts:"
echo "  • ExplicitJNITest.class (compiled test)"
echo "  • Build directory: $JAVAFX_BUILD_DIR"
echo "  • Environment file: $JAVAFX_BUILD_DIR/javafx_env.sh"
echo

echo "=========================================="
echo "JavaFX JNI Test Runner Complete"
echo "=========================================="

exit $TEST_RESULT
