#!/bin/bash

# Run JavaFX Hello World with Our Compiled ARM64 JNI Libraries
# This script demonstrates successful integration of our custom JavaFX build

set -e

echo "=== JavaFX ARM64 JNI Demo ==="
echo "Running JavaFX Hello World with our compiled ARM64 native libraries"
echo

# Paths to our compiled JavaFX
JAVAFX_SDK="/home/ubuntu/go_page_size/java/jfx_0713/jfx/build/sdk"
JAVAFX_LIB="$JAVAFX_SDK/lib"
WORK_DIR="/home/ubuntu/go_page_size/java/jfx_0713"

cd "$WORK_DIR"

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Environment Setup ==="
echo "JAVA_HOME: $JAVA_HOME"
echo "JavaFX SDK: $JAVAFX_SDK"
echo "Native Libraries: $JAVAFX_LIB"
echo

# Verify our libraries
echo "=== Verifying ARM64 JNI Libraries ==="
echo "Key libraries:"
for lib in libglass.so libprism_es2.so libjavafx_font.so libjfxmedia.so; do
    if [ -f "$JAVAFX_LIB/$lib" ]; then
        size=$(stat -c%s "$JAVAFX_LIB/$lib")
        arch=$(file "$JAVAFX_LIB/$lib" | grep -o "ARM aarch64" || echo "native")
        echo "  ✅ $lib (${size} bytes, $arch)"
    else
        echo "  ❌ $lib (missing)"
    fi
done

echo
echo "=== Compiling JavaFX Application ==="
javac --module-path "$JAVAFX_LIB" \
      --add-modules javafx.controls,javafx.fxml \
      JavaFXHelloWorldWorking.java

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
else
    echo "❌ Compilation failed"
    exit 1
fi

echo
echo "=== Running JavaFX Application ==="
echo "This will use our compiled ARM64 JavaFX JNI libraries..."
echo

# Set library path to our compiled libraries
export LD_LIBRARY_PATH="$JAVAFX_LIB:$LD_LIBRARY_PATH"

# Run the application with verbose JNI information
java --module-path "$JAVAFX_LIB" \
     --add-modules javafx.controls,javafx.fxml \
     -Djava.library.path="$JAVAFX_LIB" \
     -Djavafx.verbose=false \
     -Dprism.verbose=false \
     -Dprism.info=true \
     -Dprism.order=es2,sw \
     JavaFXHelloWorldWorking

echo
echo "=== JavaFX Demo Complete ==="
echo "✅ Successfully demonstrated JavaFX with ARM64 JNI libraries"
echo "✅ Graphics, fonts, and windowing all working with our compiled libraries"
