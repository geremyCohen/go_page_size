#!/bin/bash

# JavaFX Demo Application Runner
# Compiles and runs the Main.java demo application using the locally built JavaFX

set -e

echo "=== JavaFX ARM64 Demo Application ==="
echo

# Set JavaFX paths - use modular SDK structure like the working script
JAVAFX_SDK="./jfx/build/modular-sdk"
JAVAFX_MODULES="$JAVAFX_SDK/modules"
JAVAFX_LIBS="$JAVAFX_SDK/modules_libs"

# Set Java environment to use Java 21
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

# Check if JavaFX build exists
if [ ! -d "$JAVAFX_MODULES" ]; then
    echo "ERROR: JavaFX modular SDK not found at $JAVAFX_MODULES"
    echo "Please run the build script first: ./build_javafx_arm64.sh"
    exit 1
fi

echo "Using JavaFX modules from: $JAVAFX_MODULES"
echo "Using JavaFX native libs from: $JAVAFX_LIBS"
echo "Java version: $(java -version 2>&1 | head -1)"
echo

# Compile the application using module path (like the working script)
echo "=== Compiling Demo Application ==="
javac --module-path "$JAVAFX_MODULES" \
      --add-modules javafx.controls,javafx.fxml \
      Main.java HelloWorld.java

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

# Set library path for native libraries (like the working script)
export LD_LIBRARY_PATH="$JAVAFX_LIBS:$LD_LIBRARY_PATH"

# Run with the same parameters as the working script
java --module-path "$JAVAFX_MODULES" \
     --add-modules javafx.controls,javafx.fxml \
     -Djava.library.path="$JAVAFX_LIBS" \
     -Djavafx.verbose=false \
     -Dprism.verbose=false \
     -Dprism.info=true \
     -Dprism.order=es2,sw \
     Main

echo
echo "Demo application finished."
