#!/bin/bash

# Quick setup script to prepare JDK17 libraries for testing
# This creates symbolic links to the existing libraries with JDK17 naming

echo "=== Setting up JDK17 libraries for testing ==="

# Check if parent directory libraries exist
PARENT_DIR="../"
FRAMEWORK_LIB="$PARENT_DIR/libtensorflow_framework.so"
JNI_LIB="$PARENT_DIR/libtensorflow_jni.so"

if [ ! -f "$FRAMEWORK_LIB" ]; then
    echo "❌ Framework library not found: $FRAMEWORK_LIB"
    echo "💡 Please run the main TensorFlow compilation first"
    exit 1
fi

if [ ! -f "$JNI_LIB" ]; then
    echo "❌ JNI library not found: $JNI_LIB"
    echo "💡 Please run the main TensorFlow compilation first"
    exit 1
fi

# Create JDK17-named symbolic links
echo "Creating JDK17 library links..."

ln -sf "$FRAMEWORK_LIB" "libtensorflow_framework-jdk17.so"
ln -sf "$JNI_LIB" "libtensorflow_jni-jdk17.so"

echo "✅ Created libtensorflow_framework-jdk17.so -> $FRAMEWORK_LIB"
echo "✅ Created libtensorflow_jni-jdk17.so -> $JNI_LIB"

# Verify the links
echo ""
echo "Verifying library links:"
ls -la *.so 2>/dev/null || echo "No .so files found"

echo ""
echo "✅ JDK17 libraries ready for testing!"
echo "Now you can run: ./run_tensorflow_jdk17_test.sh SimpleJNIHelloWorldJDK17"
