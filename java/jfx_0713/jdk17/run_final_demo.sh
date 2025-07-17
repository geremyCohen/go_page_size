#!/bin/bash

# Script to compile and run FinalDemo.java with JDK17 JavaFX build
# This script uses the JavaFX build from ~/javafx_jdk17_build_20250715_221529

set -e

echo "=== JavaFX JDK17 FinalDemo Runner ==="
echo

# Set up JDK17 environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

# Set up JavaFX paths - find the most recent successful build
JAVAFX_BUILD_DIR=$(find $HOME -name "javafx_jdk17_build_*" -type d | sort | tail -1)
if [ -n "$JAVAFX_BUILD_DIR" ]; then
    JAVAFX_SDK_DIR="$JAVAFX_BUILD_DIR/jfx/build/sdk"
    if [ -d "$JAVAFX_SDK_DIR" ]; then
        export JAVAFX_HOME="$JAVAFX_SDK_DIR"
        export JAVAFX_LIB="$JAVAFX_HOME/lib"
    else
        echo "⚠️  SDK directory not found, using base module only"
        export JAVAFX_HOME="$JAVAFX_BUILD_DIR/jfx/build"
        export JAVAFX_LIB="$JAVAFX_HOME/sdk/lib"
    fi
else
    echo "❌ No JavaFX build directory found"
    exit 1
fi

echo "Java Home: $JAVA_HOME"
echo "JavaFX Home: $JAVAFX_HOME"
echo "JavaFX Lib: $JAVAFX_LIB"
echo

# Verify JDK17
echo "=== Verifying JDK17 ==="
java -version
echo

# Check if JavaFX build exists
if [ ! -d "$JAVAFX_LIB" ]; then
    echo "❌ ERROR: JavaFX build directory not found: $JAVAFX_LIB"
    echo "Please ensure the JavaFX build completed successfully."
    echo "Expected location: $JAVAFX_BUILD_DIR"
    exit 1
fi

echo "✅ JavaFX build directory found: $JAVAFX_LIB"

# List JavaFX JAR files
echo
echo "=== Available JavaFX JAR Files ==="
ls -la "$JAVAFX_LIB"/*.jar 2>/dev/null || echo "No JAR files found"

# List native libraries
echo
echo "=== Available Native Libraries ==="
ls -la "$JAVAFX_LIB"/*.so 2>/dev/null || echo "No .so files found"

echo
echo "=== Compiling FinalDemo.java ==="

# Compile the Java file
javac --module-path "$JAVAFX_LIB" \
      --add-modules javafx.controls,javafx.fxml \
      FinalDemo.java

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
else
    echo "❌ Compilation failed"
    exit 1
fi

echo
echo "=== Running FinalDemo ==="

# Check for display
if [ -z "$DISPLAY" ]; then
    echo "⚠️  No DISPLAY environment variable set."
    echo "Setting up virtual display for headless testing..."
    
    # Try to start Xvfb for headless testing
    if command -v Xvfb >/dev/null 2>&1; then
        echo "Starting Xvfb virtual display..."
        Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
        XVFB_PID=$!
        export DISPLAY=:99.0
        sleep 2
        echo "Virtual display started: $DISPLAY"
    else
        echo "Xvfb not available. Install with: sudo apt install xvfb"
        echo "Or run with X11 forwarding: ssh -X user@host"
    fi
fi

# Run the JavaFX application
echo "Launching JavaFX JDK17 application..."
java --module-path "$JAVAFX_LIB" \
     --add-modules javafx.controls,javafx.fxml \
     --add-opens javafx.graphics/com.sun.javafx.application=ALL-UNNAMED \
     -Djava.awt.headless=false \
     -Dprism.order=sw \
     -Dprism.verbose=true \
     FinalDemo

DEMO_EXIT_CODE=$?

# Clean up virtual display if we started it
if [ ! -z "$XVFB_PID" ]; then
    echo "Stopping virtual display..."
    kill $XVFB_PID 2>/dev/null || true
fi

echo
if [ $DEMO_EXIT_CODE -eq 0 ]; then
    echo "✅ FinalDemo completed successfully!"
    echo "✅ JDK17 + JavaFX 21 + ARM64 JNI: All working!"
else
    echo "❌ FinalDemo failed with exit code: $DEMO_EXIT_CODE"
    echo
    echo "Troubleshooting:"
    echo "1. Check JavaFX build: ls -la $JAVAFX_LIB"
    echo "2. Verify JDK17: java -version"
    echo "3. Check display: echo \$DISPLAY"
    echo "4. Try with X11 forwarding: ssh -X user@host"
fi

echo
echo "=== Script Complete ==="
