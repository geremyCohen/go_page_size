#!/bin/bash

# Final JavaFX JNI Test Runner Script
# Runs ExplicitJNITest_Final with system libraries

set -e

echo "=========================================="
echo "JavaFX JNI Test Runner (FINAL)"
echo "Testing Native JNI Libraries"
echo "=========================================="
echo

# Set up JDK17
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-arm64}
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Environment Setup ==="
echo "✅ Java Home: $JAVA_HOME"
echo "✅ Java Version: $(java -version 2>&1 | head -1)"
echo "✅ Architecture: $(uname -m)"
echo

# Check for system JavaFX libraries
echo "=== System JavaFX Libraries Check ==="
SYSTEM_JNI_DIR="/usr/lib/aarch64-linux-gnu/jni"
if [ -d "$SYSTEM_JNI_DIR" ]; then
    SO_COUNT=$(find "$SYSTEM_JNI_DIR" -name "*.so" | wc -l)
    if [ $SO_COUNT -gt 0 ]; then
        echo "✅ Found $SO_COUNT native libraries in system JNI directory"
        echo "Sample libraries:"
        find "$SYSTEM_JNI_DIR" -name "*.so" | head -5 | while read lib; do
            echo "  • $(basename "$lib")"
        done
        if [ $SO_COUNT -gt 5 ]; then
            echo "  • ... and $((SO_COUNT - 5)) more"
        fi
    else
        echo "❌ No native libraries found in system JNI directory"
        echo "Please install libopenjfx-jni package"
        exit 1
    fi
else
    echo "❌ System JNI directory not found"
    echo "Please install libopenjfx-jni package"
    exit 1
fi

echo

# Set up classpath
echo "=== Classpath Configuration ==="
CLASSPATH="."

# Add system JavaFX JARs
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

# Compile ExplicitJNITest_Final
echo "=== Compiling ExplicitJNITest_Final ==="
javac -cp "$CLASSPATH" ExplicitJNITest_Final.java

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
else
    echo "❌ Compilation failed"
    exit 1
fi

echo

# Run the test
echo "=== Running ExplicitJNITest_Final ==="
echo "This test will:"
echo "  1. Load system JavaFX .so libraries explicitly"
echo "  2. Call real JavaFX native methods"
echo "  3. Demonstrate end-to-end JNI communication"
echo

# Set library path for native libraries
export LD_LIBRARY_PATH="$SYSTEM_JNI_DIR:$LD_LIBRARY_PATH"

echo "Starting ExplicitJNITest_Final..."
echo "----------------------------------------"

java -cp "$CLASSPATH" \
     -Djava.library.path="$SYSTEM_JNI_DIR" \
     -Dprism.order=sw \
     -Dprism.verbose=false \
     -Djava.awt.headless=true \
     ExplicitJNITest_Final

TEST_RESULT=$?

echo "----------------------------------------"

if [ $TEST_RESULT -eq 0 ]; then
    echo
    echo "🎉 ExplicitJNITest_Final completed successfully!"
    echo
    echo "✅ Native libraries loaded and tested"
    echo "✅ JavaFX JNI integration working"
    echo "✅ ARM64 native code execution verified"
    echo "✅ End-to-end communication: Java ↔ Native Libraries"
else
    echo
    echo "❌ ExplicitJNITest_Final failed with exit code: $TEST_RESULT"
fi

echo

echo "=========================================="
echo "JavaFX JNI Test Runner Complete"
echo "=========================================="

exit $TEST_RESULT
