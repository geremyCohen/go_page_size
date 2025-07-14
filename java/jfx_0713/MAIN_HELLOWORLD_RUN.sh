#!/bin/bash

# Main + HelloWorld JavaFX ARM64 Application Runner
# Your original requested demo structure with interactive UI

set -e

echo "=== Main + HelloWorld JavaFX ARM64 Application ==="
echo "Original demo structure: Main extends Application with HelloWorld scene"
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

# Compile Main and HelloWorld
echo "=== Compiling Main + HelloWorld ==="
javac -cp "$JAVAFX_CLASSPATH" Main.java HelloWorld.java

if [ $? -eq 0 ]; then
    echo "✅ Main + HelloWorld compilation successful"
else
    echo "❌ Main + HelloWorld compilation failed"
    exit 1
fi

echo

# Set library path for native libraries
export LD_LIBRARY_PATH="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base:$LD_LIBRARY_PATH"

# Display native library status
echo "✅ ARM64 Native Libraries Loaded:"
find "$JAVAFX_LIBS" -name "*.so" | head -3 | while read lib; do
    basename_lib=$(basename "$lib")
    echo "   📚 $basename_lib"
done
echo

# Run Main application
echo "=== Running Main Application ==="
echo "Note: Features interactive buttons, click counter, and system info"
echo

java -cp ".:$JAVAFX_CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base" \
     -Dprism.order=sw,es2 \
     -Dprism.verbose=false \
     -Dglass.platform=gtk \
     Main

echo
echo "=== Main + HelloWorld Demo Complete ==="
