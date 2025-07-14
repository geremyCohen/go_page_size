#!/bin/bash

# FinalDemo JavaFX ARM64 Application Runner
# Complete standalone script with all dependencies - FIXED VERSION

set -e

echo "=== FinalDemo JavaFX ARM64 Application ==="
echo "Comprehensive demo with display detection and UI interaction"
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

echo "✅ Environment Setup:"
echo "   Java: $(java -version 2>&1 | head -1)"
echo "   Architecture: $(uname -m)"
echo "   JavaFX Modules: $JAVAFX_MODULES"
echo "   Native Libraries: $JAVAFX_LIBS"
echo

# Build classpath with all JavaFX module directories
JAVAFX_CLASSPATH="$JAVAFX_MODULES/javafx.base:$JAVAFX_MODULES/javafx.graphics:$JAVAFX_MODULES/javafx.controls:$JAVAFX_MODULES/javafx.fxml"

# Compile FinalDemo
echo "=== Compiling FinalDemo ==="
javac -cp "$JAVAFX_CLASSPATH" FinalDemo.java

if [ $? -eq 0 ]; then
    echo "✅ FinalDemo compilation successful"
else
    echo "❌ FinalDemo compilation failed"
    exit 1
fi

echo

# Set library path for native libraries - include all paths
export LD_LIBRARY_PATH="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base:$LD_LIBRARY_PATH"

# Display native library status
echo "✅ ARM64 Native Libraries Loaded:"
find "$JAVAFX_LIBS" -name "*.so" | head -3 | while read lib; do
    basename_lib=$(basename "$lib")
    echo "   📚 $basename_lib"
done
echo

# Check for display
DISPLAY_STATUS="unknown"
if [ -n "$DISPLAY" ]; then
    DISPLAY_STATUS="available ($DISPLAY)"
else
    DISPLAY_STATUS="not available (headless mode)"
    echo "⚠️  No DISPLAY variable set - running in headless mode"
fi

echo "Display status: $DISPLAY_STATUS"
echo

# Run FinalDemo with comprehensive JavaFX runtime arguments
echo "=== Running FinalDemo ==="
echo "Note: This demo includes display detection and comprehensive UI"
echo

# Add comprehensive JVM arguments to fix runtime components issue
java -cp ".:$JAVAFX_CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base" \
     -Djavafx.platform=linux \
     -Dprism.order=sw,es2 \
     -Dprism.verbose=false \
     -Dglass.platform=gtk \
     -Djavafx.toolkit=quantum \
     -Dquantum.multithreaded=false \
     --add-opens java.base/java.lang=ALL-UNNAMED \
     --add-opens java.base/java.lang.reflect=ALL-UNNAMED \
     --add-opens java.base/java.util=ALL-UNNAMED \
     --add-opens java.desktop/java.awt=ALL-UNNAMED \
     --add-exports javafx.base/com.sun.javafx.runtime=ALL-UNNAMED \
     --add-exports javafx.graphics/com.sun.javafx.tk=ALL-UNNAMED \
     FinalDemo

echo
echo "=== FinalDemo Complete ==="
