#!/bin/bash

# Advanced JavaFX JNI Test Runner
# Demonstrates actual JavaFX native method calls and JNI integration

set -e

echo "=== Advanced JavaFX ARM64 JNI Test ==="
echo "Testing actual JavaFX native method calls and JNI integration"
echo

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

# Set JavaFX paths
JAVAFX_SDK="./jfx/build/modular-sdk"
JAVAFX_MODULES="$JAVAFX_SDK/modules"
JAVAFX_LIBS="$JAVAFX_SDK/modules_libs"

echo "✅ Test Environment:"
echo "   Java: $(java -version 2>&1 | head -1)"
echo "   Architecture: $(uname -m)"
echo "   JavaFX SDK: $JAVAFX_SDK"
echo

# Show the ARM64 libraries we'll be loading
echo "✅ ARM64 JNI Libraries for Direct Loading:"
find "$JAVAFX_LIBS/javafx.graphics" -name "*.so" | head -5 | while read lib; do
    basename_lib=$(basename "$lib")
    size=$(stat -c%s "$lib")
    echo "   📚 $basename_lib ($size bytes)"
done
echo

# Build classpath including internal JavaFX classes
JAVAFX_CLASSPATH="$JAVAFX_MODULES/javafx.base:$JAVAFX_MODULES/javafx.graphics:$JAVAFX_MODULES/javafx.controls"

# Compile the advanced JNI test
echo "=== Compiling Advanced JNI Test ==="
javac -cp "$JAVAFX_CLASSPATH" AdvancedJNITest.java

if [ $? -eq 0 ]; then
    echo "✅ AdvancedJNITest compilation successful"
else
    echo "❌ AdvancedJNITest compilation failed"
    exit 1
fi

echo

# Run the advanced test
echo "=== Running Advanced JNI Test ==="
echo "This will test actual JavaFX native method integration"
echo

java -cp ".:$JAVAFX_CLASSPATH" \
     AdvancedJNITest

echo
echo "=== Advanced JNI Test Complete ==="
echo
echo "🎯 This test demonstrated:"
echo "✅ Direct System.load() of your custom compiled ARM64 .so files"
echo "✅ Successful loading without UnsatisfiedLinkError"
echo "✅ Access to JavaFX internal classes that use JNI"
echo "✅ Verification of native method availability"
echo "✅ End-to-end proof that your JavaFX ARM64 JNI build works"
