#!/bin/bash

# Compile and Run JavaFX Hello World with Explicit JNI Loading
# This script compiles and runs our JavaFX application using the ARM64 libraries we built

set -e

echo "=== JavaFX Hello World - Compile and Run Script ==="
echo "Using our compiled ARM64 JavaFX libraries with explicit JNI loading"
echo

# Paths to our compiled JavaFX
JAVAFX_SDK="/home/ubuntu/go_page_size/java/jfx_0713/jfx/build/sdk"
JAVAFX_LIB="$JAVAFX_SDK/lib"
WORK_DIR="/home/ubuntu/go_page_size/java/jfx_0713"

cd "$WORK_DIR"

# Verify our JavaFX libraries exist
echo "=== Verifying JavaFX Libraries ==="
if [ ! -d "$JAVAFX_LIB" ]; then
    echo "ERROR: JavaFX library directory not found: $JAVAFX_LIB"
    echo "Please run the JavaFX build script first."
    exit 1
fi

echo "✓ JavaFX SDK found: $JAVAFX_SDK"
echo "✓ JavaFX libraries found: $JAVAFX_LIB"

# List our compiled native libraries
echo
echo "=== Our Compiled ARM64 JNI Libraries ==="
ls -la "$JAVAFX_LIB"/*.so | head -10
echo "... and more"

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

echo
echo "=== Java Environment ==="
echo "JAVA_HOME: $JAVA_HOME"
java -version

# Compile the JavaFX application
echo
echo "=== Compiling JavaFX Hello World Application ==="
echo "Compiling with module path pointing to our compiled JavaFX..."

javac --module-path "$JAVAFX_LIB" \
      --add-modules javafx.controls,javafx.fxml \
      JavaFXHelloWorld.java

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
else
    echo "✗ Compilation failed"
    exit 1
fi

# Run the application
echo
echo "=== Running JavaFX Application with Explicit JNI Loading ==="
echo "This will explicitly load our ARM64 compiled JavaFX native libraries"
echo

# Set library path to our compiled libraries
export LD_LIBRARY_PATH="$JAVAFX_LIB:$LD_LIBRARY_PATH"

# Run with our compiled JavaFX
java --module-path "$JAVAFX_LIB" \
     --add-modules javafx.controls,javafx.fxml \
     -Djava.library.path="$JAVAFX_LIB" \
     -Djavafx.verbose=true \
     -Dprism.verbose=true \
     -Dprism.info=true \
     JavaFXHelloWorld

echo
echo "=== Application Execution Complete ==="
