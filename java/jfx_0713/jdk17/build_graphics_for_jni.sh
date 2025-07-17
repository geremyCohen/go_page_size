#!/bin/bash

# Build JavaFX Graphics Module for JNI Testing - JDK17
# This builds the graphics module which contains the native .so libraries needed for JNI testing

set -e

echo "=== JavaFX Graphics Module Build for JNI Testing - JDK17 ==="
echo "This builds the graphics module to generate native .so libraries"
echo

# Set up JDK17 environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

echo "Java Version: $(java -version 2>&1 | head -1)"
echo "Architecture: $(uname -m)"
echo

# Use existing build directory
BUILD_DIR="/home/ubuntu/javafx_jdk17_build_20250715_234005"
cd "$BUILD_DIR/jfx"

echo "Build directory: $BUILD_DIR/jfx"
echo

# Create gradle.properties optimized for graphics module with native libraries
echo "=== Creating Gradle Configuration for Graphics Module with Native Libraries ==="
cat > gradle.properties << 'EOF'
# ARM64 Linux build configuration for JDK17 - Graphics module with native libraries
COMPILE_TARGETS = linux
CONF = Release

# Enable native compilation for JNI libraries
BUILD_LIBAV_STUBS = false
BUILD_GSTREAMER = true
COMPILE_WEBKIT = false
BUILD_FXPACKAGER = false
BUILD_JAVADOC = false

# ARM64 specific settings
LINUX_TARGET_ARCH = aarch64

# JDK17 compatibility
COMPILE_JDK_VERSION = 17
TARGET_JDK_VERSION = 17

# Performance settings for native compilation
org.gradle.parallel = true
org.gradle.daemon = true
org.gradle.jvmargs = -Xmx4g -XX:MaxMetaspaceSize=1g

# Enable verbose native compilation
COMPILE_VERBOSE_JNI = true
EOF

echo "✅ Created gradle.properties optimized for native library generation"
echo

# Build the graphics module which contains most native JNI libraries
echo "=== Building JavaFX Graphics Module (Contains Native JNI Libraries) ==="
echo "This will compile ARM64 native libraries (.so files) for JNI testing..."
echo "Expected libraries: libglass.so, libprism_es2.so, libjavafx_font.so, etc."
echo

# Build graphics module step by step to monitor progress
echo "Step 1: Building graphics module Java sources..."
./gradlew :graphics:compileJava --info --no-daemon

if [ $? -ne 0 ]; then
    echo "❌ Graphics module Java compilation failed"
    exit 1
fi

echo "✅ Graphics Java compilation successful"
echo

echo "Step 2: Building native JNI libraries for graphics..."
./gradlew :graphics:nativeGlass --info --no-daemon

if [ $? -ne 0 ]; then
    echo "⚠️  Glass native library build may have issues, continuing..."
fi

echo "Step 3: Building Prism native libraries (ES2 graphics pipeline)..."
./gradlew :graphics:nativePrismES2 --info --no-daemon

if [ $? -ne 0 ]; then
    echo "⚠️  Prism ES2 native library build may have issues, continuing..."
fi

echo "Step 4: Building font native libraries..."
./gradlew :graphics:nativeFont --info --no-daemon

if [ $? -ne 0 ]; then
    echo "⚠️  Font native library build may have issues, continuing..."
fi

echo "Step 5: Building all graphics native libraries..."
./gradlew :buildModuleGraphicsLinux --info --no-daemon

if [ $? -ne 0 ]; then
    echo "⚠️  Some native libraries may not have built, checking what we got..."
fi

# Check what native libraries were created
echo
echo "=== Checking Generated Native Libraries ==="

# Look for .so files in various locations
NATIVE_LIBS_FOUND=0

echo "Searching for native libraries..."
for search_dir in "build/sdk/lib" "modules/javafx.graphics/build" "build"; do
    if [ -d "$search_dir" ]; then
        echo "Checking $search_dir:"
        find "$search_dir" -name "*.so" 2>/dev/null | while read lib; do
            if [ -f "$lib" ]; then
                echo "  ✅ Found: $lib ($(du -h "$lib" | cut -f1))"
                echo "     Architecture: $(file "$lib" | grep -o 'ARM aarch64' || echo 'Native library')"
                NATIVE_LIBS_FOUND=$((NATIVE_LIBS_FOUND + 1))
            fi
        done
    fi
done

# Also check the SDK lib directory specifically
SDK_LIB_DIR="build/sdk/lib"
if [ -d "$SDK_LIB_DIR" ]; then
    echo
    echo "=== SDK Library Directory Contents ==="
    ls -la "$SDK_LIB_DIR"
    
    SO_COUNT=$(find "$SDK_LIB_DIR" -name "*.so" | wc -l)
    JAR_COUNT=$(find "$SDK_LIB_DIR" -name "*.jar" | wc -l)
    
    echo
    echo "Library Summary:"
    echo "  JAR files: $JAR_COUNT"
    echo "  Native libraries (.so): $SO_COUNT"
    
    if [ $SO_COUNT -gt 0 ]; then
        echo
        echo "✅ Native libraries generated successfully!"
        echo "Available for JNI testing:"
        find "$SDK_LIB_DIR" -name "*.so" | while read lib; do
            echo "  - $(basename "$lib")"
        done
        
        # Test the JavaFXJNITest if native libraries are available
        echo
        echo "=== Testing JNI Library Loading ==="
        cd /home/ubuntu/go_page_size/java/jfx_0713
        
        if [ -f "JavaFXJNITest.java" ]; then
            echo "Compiling JavaFXJNITest..."
            javac JavaFXJNITest.java
            
            if [ $? -eq 0 ]; then
                echo "Running JNI library loading test..."
                java JavaFXJNITest
            else
                echo "❌ JavaFXJNITest compilation failed"
            fi
        else
            echo "JavaFXJNITest.java not found in parent directory"
        fi
    else
        echo "⚠️  No native libraries (.so files) were generated"
        echo "This may be due to missing native dependencies or build configuration issues"
    fi
else
    echo "❌ SDK lib directory not found: $SDK_LIB_DIR"
fi

echo
echo "=== Graphics Module Build Complete ==="
echo "Build location: $BUILD_DIR/jfx"
echo "Check the output above for available native libraries for JNI testing"
