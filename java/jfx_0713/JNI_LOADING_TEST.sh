#!/bin/bash

# JNI Loading Test - Shows explicit JNI library loading for JavaFX ARM64

set -e

echo "=== JavaFX ARM64 JNI Loading Test ==="
echo "This script shows detailed JNI library loading information"
echo

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

# Set JavaFX paths
JAVAFX_SDK="./jfx/build/modular-sdk"
JAVAFX_MODULES="$JAVAFX_SDK/modules"
JAVAFX_LIBS="$JAVAFX_SDK/modules_libs"

echo "✅ JNI Library Locations:"
echo "   Graphics: $JAVAFX_LIBS/javafx.graphics"
echo "   Media: $JAVAFX_LIBS/javafx.media"
echo "   Base: $JAVAFX_LIBS/javafx.base"
echo

# Show available JNI libraries
echo "✅ Available ARM64 JNI Libraries:"
find "$JAVAFX_LIBS" -name "*.so" | while read lib; do
    basename_lib=$(basename "$lib")
    size=$(stat -c%s "$lib")
    arch=$(file "$lib" | grep -o "ARM aarch64" || echo "native")
    echo "   📚 $basename_lib ($size bytes, $arch)"
done
echo

# Build classpath
JAVAFX_CLASSPATH="$JAVAFX_MODULES/javafx.base:$JAVAFX_MODULES/javafx.graphics:$JAVAFX_MODULES/javafx.controls"

# Set library paths for JNI loading
export LD_LIBRARY_PATH="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base:$LD_LIBRARY_PATH"

echo "✅ JNI Loading Configuration:"
echo "   LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "   java.library.path will be set to: $JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base"
echo

# Compile simple test
echo "=== Compiling JNI Loading Test ==="
javac -cp "$JAVAFX_CLASSPATH" SimpleTest.java

echo "=== Running JNI Loading Test with Verbose Output ==="
echo "Watch for 'Loading ... native library' messages:"
echo

# Run with maximum JNI and library loading verbosity
java -cp ".:$JAVAFX_CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base" \
     -Dprism.verbose=true \
     -Dprism.debug=true \
     -Djavafx.verbose=true \
     -Djava.awt.debug=true \
     -verbose:jni \
     SimpleTest

echo
echo "=== JNI Loading Test Complete ==="
echo "Look for 'Loading ... native library ... succeeded' messages above"
