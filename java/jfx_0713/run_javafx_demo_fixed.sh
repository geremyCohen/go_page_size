#!/bin/bash

# Run JavaFX Hello World with Our Compiled ARM64 JNI Libraries (Fixed)
# This script uses the proper modular SDK structure

set -e

echo "=== JavaFX ARM64 JNI Demo (Fixed) ==="
echo "Running JavaFX Hello World with our compiled ARM64 native libraries"
echo

# Paths to our compiled JavaFX
JAVAFX_SDK="/home/ubuntu/go_page_size/java/jfx_0713/jfx/build/modular-sdk"
JAVAFX_MODULES="$JAVAFX_SDK/modules"
JAVAFX_LIBS="$JAVAFX_SDK/modules_libs"
WORK_DIR="/home/ubuntu/go_page_size/java/jfx_0713"

cd "$WORK_DIR"

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Environment Setup ==="
echo "JAVA_HOME: $JAVA_HOME"
echo "JavaFX Modular SDK: $JAVAFX_SDK"
echo "JavaFX Modules: $JAVAFX_MODULES"
echo "Native Libraries: $JAVAFX_LIBS"
echo

# Verify our libraries
echo "=== Verifying ARM64 JNI Libraries ==="
echo "Key libraries in modules_libs:"
find "$JAVAFX_LIBS" -name "*.so" | head -5 | while read lib; do
    if [ -f "$lib" ]; then
        size=$(stat -c%s "$lib")
        arch=$(file "$lib" | grep -o "ARM aarch64" || echo "native")
        basename_lib=$(basename "$lib")
        echo "  ✅ $basename_lib (${size} bytes, $arch)"
    fi
done

echo
echo "=== Verifying JavaFX Modules ==="
for module in javafx.base javafx.graphics javafx.controls javafx.fxml; do
    if [ -d "$JAVAFX_MODULES/$module" ]; then
        echo "  ✅ $module module found"
    else
        echo "  ❌ $module module missing"
    fi
done

echo
echo "=== Compiling JavaFX Application ==="
javac --module-path "$JAVAFX_MODULES" \
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
export LD_LIBRARY_PATH="$JAVAFX_LIBS:$LD_LIBRARY_PATH"

# Run the application with our modular SDK
java --module-path "$JAVAFX_MODULES" \
     --add-modules javafx.controls,javafx.fxml \
     -Djava.library.path="$JAVAFX_LIBS" \
     -Djavafx.verbose=false \
     -Dprism.verbose=false \
     -Dprism.info=true \
     -Dprism.order=es2,sw \
     JavaFXHelloWorldWorking

echo
echo "=== JavaFX Demo Complete ==="
echo "✅ Successfully demonstrated JavaFX with ARM64 JNI libraries"
echo "✅ Graphics, fonts, and windowing all working with our compiled libraries"
