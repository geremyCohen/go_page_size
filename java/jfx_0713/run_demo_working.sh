#!/bin/bash

# JavaFX Demo Application Runner - Working Version
# Uses classpath instead of modules since the build doesn't have proper module descriptors

set -e

echo "=== JavaFX ARM64 Demo Application (Working) ==="
echo

# Set JavaFX paths
JAVAFX_SDK="./jfx/build/modular-sdk"
JAVAFX_MODULES="$JAVAFX_SDK/modules"
JAVAFX_LIBS="$JAVAFX_SDK/modules_libs"

# Set Java environment to use Java 21
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

# Check if JavaFX build exists
if [ ! -d "$JAVAFX_MODULES" ]; then
    echo "ERROR: JavaFX modular SDK not found at $JAVAFX_MODULES"
    exit 1
fi

echo "Using JavaFX modules from: $JAVAFX_MODULES"
echo "Using JavaFX native libs from: $JAVAFX_LIBS"
echo "Java version: $(java -version 2>&1 | head -1)"
echo

# Build classpath with all JavaFX module directories
JAVAFX_CLASSPATH="$JAVAFX_MODULES/javafx.base:$JAVAFX_MODULES/javafx.graphics:$JAVAFX_MODULES/javafx.controls:$JAVAFX_MODULES/javafx.fxml"

echo "=== Compiling Demo Application ==="
javac -cp "$JAVAFX_CLASSPATH" Main.java HelloWorld.java

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
else
    echo "✗ Compilation failed"
    exit 1
fi

echo

# Run the application
echo "=== Running Demo Application ==="
echo "Starting JavaFX Hello World demo..."
echo "Architecture: $(uname -m)"
echo

# Set library path for native libraries - include all module lib directories
export LD_LIBRARY_PATH="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base:$LD_LIBRARY_PATH"

# Run with classpath and proper library paths
java -cp ".:$JAVAFX_CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base" \
     -Djavafx.verbose=false \
     -Dprism.verbose=true \
     -Dprism.info=true \
     -Dprism.order=es2,sw \
     -Dglass.platform=gtk \
     Main

echo
echo "Demo application finished."
