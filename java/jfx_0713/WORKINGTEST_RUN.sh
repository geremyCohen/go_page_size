#!/bin/bash

# WorkingTest JavaFX ARM64 Application Runner
# Platform initialization test using JFXPanel trick

set -e

echo "=== WorkingTest JavaFX ARM64 Application ==="
echo "Platform initialization test with proper JavaFX toolkit setup"
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

# Build classpath with all JavaFX module directories (including swing for JFXPanel)
JAVAFX_CLASSPATH="$JAVAFX_MODULES/javafx.base:$JAVAFX_MODULES/javafx.graphics:$JAVAFX_MODULES/javafx.controls:$JAVAFX_MODULES/javafx.fxml:$JAVAFX_MODULES/javafx.swing"

# Compile WorkingTest
echo "=== Compiling WorkingTest ==="
javac -cp "$JAVAFX_CLASSPATH" WorkingTest.java

if [ $? -eq 0 ]; then
    echo "✅ WorkingTest compilation successful"
else
    echo "❌ WorkingTest compilation failed"
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

# Run WorkingTest
echo "=== Running WorkingTest ==="
echo "Note: This test uses JFXPanel to initialize JavaFX platform properly"
echo "Expected: Will show platform initialization and Scene creation success"
echo

java -cp ".:$JAVAFX_CLASSPATH" \
     -Djava.library.path="$JAVAFX_LIBS/javafx.graphics:$JAVAFX_LIBS/javafx.media:$JAVAFX_LIBS/javafx.base" \
     -Dprism.order=sw,es2 \
     -Dprism.verbose=false \
     -Djava.awt.headless=false \
     WorkingTest

echo
echo "=== WorkingTest Complete ==="
echo "Note: This test demonstrates proper JavaFX platform initialization"
