#!/bin/bash

# Build minimal native libraries for JNI testing - JDK17
# Focus on just the essential .so files needed for JavaFXJNITest

set -e

echo "=== Minimal Native Libraries Build for JNI Testing ==="
echo "Building only essential .so libraries for JavaFXJNITest"
echo

# Set up environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

BUILD_DIR="/home/ubuntu/javafx_jdk17_build_20250715_234005"
cd "$BUILD_DIR/jfx"

echo "Build directory: $BUILD_DIR/jfx"
echo "Java version: $(java -version 2>&1 | head -1)"
echo

# Create minimal gradle.properties for native compilation
cat > gradle.properties << 'EOF'
COMPILE_TARGETS = linux
CONF = Release
BUILD_LIBAV_STUBS = false
BUILD_GSTREAMER = false
COMPILE_WEBKIT = false
BUILD_FXPACKAGER = false
BUILD_JAVADOC = false
LINUX_TARGET_ARCH = aarch64
COMPILE_JDK_VERSION = 17
TARGET_JDK_VERSION = 17
org.gradle.parallel = false
org.gradle.daemon = false
org.gradle.jvmargs = -Xmx2g
EOF

echo "✅ Created minimal gradle configuration"

# Try to build native libraries one by one with short timeouts
echo
echo "=== Building Essential Native Libraries ==="

# 1. Try to build font library (usually fastest)
echo "Building font library..."
timeout 180 ./gradlew :graphics:nativeFont --no-daemon --info || echo "Font library build timed out"

# 2. Try to build glass library (windowing)
echo "Building glass library..."
timeout 180 ./gradlew :graphics:nativeGlass --no-daemon --info || echo "Glass library build timed out"

# 3. Try to build prism library (graphics)
echo "Building prism library..."
timeout 180 ./gradlew :graphics:nativePrism --no-daemon --info || echo "Prism library build timed out"

# Check what we got
echo
echo "=== Checking for Generated Libraries ==="

# Look for any .so files that were created
find . -name "*.so" -type f 2>/dev/null | while read lib; do
    echo "✅ Found: $lib"
    echo "   Size: $(du -h "$lib" | cut -f1)"
    echo "   Type: $(file "$lib" 2>/dev/null | head -1)"
    echo
done

# Copy any found libraries to SDK lib directory
SDK_LIB_DIR="build/sdk/lib"
mkdir -p "$SDK_LIB_DIR"

SO_FILES=$(find . -name "*.so" -type f 2>/dev/null)
if [ -n "$SO_FILES" ]; then
    echo "Copying native libraries to SDK directory..."
    find . -name "*.so" -type f -exec cp {} "$SDK_LIB_DIR/" \;
    
    echo "Libraries in SDK:"
    ls -la "$SDK_LIB_DIR"/*.so 2>/dev/null || echo "No .so files in SDK"
else
    echo "⚠️  No native libraries were generated"
fi

echo
echo "=== Build Summary ==="
SO_COUNT=$(find "$SDK_LIB_DIR" -name "*.so" 2>/dev/null | wc -l)
echo "Native libraries (.so) in SDK: $SO_COUNT"

if [ $SO_COUNT -gt 0 ]; then
    echo "✅ Some native libraries were built!"
    echo "Available for JNI testing:"
    ls -1 "$SDK_LIB_DIR"/*.so 2>/dev/null | xargs -I {} basename {}
else
    echo "❌ No native libraries were successfully built"
    echo "This may require a longer build time or additional dependencies"
fi
