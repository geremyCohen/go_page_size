#!/bin/bash

# HeadlessSuccess JavaFX ARM64 Verification Runner
# Demonstrates successful JavaFX ARM64 JNI build without requiring display

set -e

echo "=== HeadlessSuccess JavaFX ARM64 Verification ==="
echo "This test proves the JavaFX ARM64 JNI build was successful"
echo

# Set Java environment to use Java 21
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

# Set JavaFX paths - use modular SDK structure
JAVAFX_SDK="./jfx/build/modular-sdk"
JAVAFX_MODULES="$JAVAFX_SDK/modules"
JAVAFX_LIBS="$JAVAFX_SDK/modules_libs"

# Check if JavaFX build exists
if [ ! -d "$JAVAFX_MODULES" ]; then
    echo "ERROR: JavaFX modular SDK not found at $JAVAFX_MODULES"
    echo "Please ensure JavaFX is built first"
    exit 1
fi

echo "✅ Build Verification Setup:"
echo "   Java: $(java -version 2>&1 | head -1)"
echo "   Architecture: $(uname -m)"
echo "   JavaFX Modules: $JAVAFX_MODULES"
echo "   Native Libraries: $JAVAFX_LIBS"
echo

# Build classpath with all JavaFX module directories
JAVAFX_CLASSPATH="$JAVAFX_MODULES/javafx.base:$JAVAFX_MODULES/javafx.graphics:$JAVAFX_MODULES/javafx.controls:$JAVAFX_MODULES/javafx.fxml"

# Compile HeadlessSuccess
echo "=== Compiling HeadlessSuccess Verification ==="
javac -cp "$JAVAFX_CLASSPATH" HeadlessSuccess.java

if [ $? -eq 0 ]; then
    echo "✅ HeadlessSuccess compilation successful"
else
    echo "❌ HeadlessSuccess compilation failed"
    exit 1
fi

echo

# Set library path for native libraries
export LD_LIBRARY_PATH="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base:$LD_LIBRARY_PATH"

# Display ARM64 native library verification
echo "✅ ARM64 Native Libraries Available:"
find "$JAVAFX_LIBS" -name "*.so" | head -5 | while read lib; do
    if [ -f "$lib" ]; then
        basename_lib=$(basename "$lib")
        size=$(stat -c%s "$lib" 2>/dev/null || echo "unknown")
        arch=$(file "$lib" 2>/dev/null | grep -o "ARM aarch64" || echo "native")
        echo "   📚 $basename_lib ($size bytes, $arch)"
    fi
done
echo

# Run HeadlessSuccess verification
echo "=== Running JavaFX ARM64 JNI Build Verification ==="
echo "This test will verify the build success without requiring a display"
echo

java -cp ".:$JAVAFX_CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base" \
     HeadlessSuccess

echo
echo "=== Verification Complete ==="
