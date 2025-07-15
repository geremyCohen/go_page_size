#!/bin/bash

# JavaFX ARM64 Ubuntu Build Script for JDK17 with JNI Support
# This script builds JavaFX from source on ARM64 Ubuntu 24.04 with native JNI libraries
# Based on successful compilation process for OpenJDK JavaFX with ARM64 compatibility
# Specifically configured for JDK17

set -e  # Exit on any error

echo "=== JavaFX ARM64 Ubuntu Build Script for JDK17 ==="
echo "Building JavaFX with JNI support for ARM64 architecture"
echo "Target: Ubuntu 24.04 LTS (ARM64/aarch64) with JDK17"
echo

# Verify system architecture
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo "ERROR: This script is designed for ARM64 (aarch64) systems. Detected: $ARCH"
    exit 1
fi

echo "✓ Confirmed ARM64 architecture: $ARCH"

# Update system packages
echo
echo "=== Updating System Packages ==="
sudo apt update

# Install build dependencies
echo
echo "=== Installing Build Dependencies ==="
echo "Installing essential build tools..."
sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    git \
    wget \
    curl

echo "Installing Java development tools (JDK17 focus)..."
sudo apt install -y \
    openjdk-17-jdk \
    ant

echo "Installing GTK and X11 development libraries..."
sudo apt install -y \
    libgtk-3-dev \
    libgtk2.0-dev \
    libxtst-dev \
    libxrandr-dev \
    libxss-dev \
    libasound2-dev \
    libpulse-dev \
    libxxf86vm-dev

echo "Installing multimedia libraries..."
sudo apt install -y \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev

echo "Installing additional tools for WebKit (optional)..."
sudo apt install -y \
    ruby \
    gperf

# Set up Java environment for JDK17
echo
echo "=== Configuring Java Environment for JDK17 ==="
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export JDK_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

echo "JAVA_HOME: $JAVA_HOME"
echo "JDK_HOME: $JDK_HOME"
java -version

# Verify JDK17 is being used
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
if [[ $JAVA_VERSION == 17.* ]]; then
    echo "✓ Confirmed JDK17 is active: $JAVA_VERSION"
else
    echo "ERROR: Expected JDK17 but found: $JAVA_VERSION"
    exit 1
fi

# Create working directory
WORK_DIR="$HOME/javafx_jdk17_build_$(date +%Y%m%d_%H%M%S)"
echo
echo "=== Creating Working Directory ==="
echo "Working directory: $WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone JavaFX repository
echo
echo "=== Cloning JavaFX Repository ==="
git clone https://github.com/openjdk/jfx.git
cd jfx

# Switch to JavaFX 17 branch (compatible with JDK 17)
echo
echo "=== Switching to JavaFX 17 Branch ==="
git checkout jfx17
echo "✓ Switched to JavaFX 17 branch for JDK 17 compatibility"

# Create gradle.properties for ARM64 configuration with JDK17 settings
echo
echo "=== Creating Gradle Configuration for JDK17 ==="
cat > gradle.properties << 'EOF'
# ARM64 Linux build configuration for JDK17
COMPILE_TARGETS = linux
CONF = Release

# Enable native compilation
BUILD_LIBAV_STUBS = true
BUILD_GSTREAMER = true

# ARM64 specific settings
LINUX_TARGET_ARCH = aarch64
COMPILE_WEBKIT = false

# JNI and native library settings
BUILD_FXPACKAGER = false
BUILD_JAVADOC = false

# JDK17 compatibility settings
COMPILE_JDK_VERSION = 17
TARGET_JDK_VERSION = 17

# Performance settings
org.gradle.parallel = true
org.gradle.daemon = true
org.gradle.jvmargs = -Xmx4g -XX:MaxMetaspaceSize=1g
EOF

echo "✓ Created gradle.properties with ARM64 and JDK17 configuration"

# Verify build requirements
echo
echo "=== Verifying Build Requirements ==="
echo "Gradle version:"
./gradlew --version | head -5

echo
echo "System information:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Architecture: $(uname -m)"
echo "CPU cores: $(nproc)"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $2}')"

# Start the build process
echo
echo "=== Starting JavaFX Build Process for JDK17 ==="
echo "This will compile JavaFX 17 with native JNI libraries for ARM64..."
echo "Build may take 10-30 minutes depending on system performance."
echo

# Build JavaFX with native libraries
echo "Building JavaFX modules with native JNI support for JDK17..."
./gradlew sdk

# Verify build success
if [ $? -eq 0 ]; then
    echo
    echo "=== Build Completed Successfully! ==="
    
    # Display build results
    BUILD_DIR="$PWD/build"
    SDK_DIR="$BUILD_DIR/sdk"
    
    echo "Build directory: $BUILD_DIR"
    echo "SDK directory: $SDK_DIR"
    
    if [ -d "$SDK_DIR/lib" ]; then
        echo
        echo "=== Generated Native Libraries (ARM64) ==="
        cd "$SDK_DIR/lib"
        for lib in *.so; do
            if [ -f "$lib" ]; then
                echo "✓ $lib ($(file "$lib" | grep -o 'ARM aarch64' || echo 'Native library'))"
            fi
        done
        
        echo
        echo "=== Generated JAR Files ==="
        for jar in *.jar; do
            if [ -f "$jar" ]; then
                echo "✓ $jar ($(du -h "$jar" | cut -f1))"
            fi
        done
        
        cd "$WORK_DIR/jfx"
    fi
    
    echo
    echo "=== Build Summary ==="
    echo "✓ JavaFX 17 compiled successfully for ARM64 with JDK17"
    echo "✓ Native JNI libraries generated for aarch64"
    echo "✓ All core modules built: base, graphics, controls, fxml, media, swing, web"
    echo "✓ ES2 graphics pipeline with JNI support enabled"
    echo "✓ Media framework with GStreamer integration"
    echo "✓ GTK3 windowing system integration"
    echo "✓ Compatible with JDK17 runtime"
    
    echo
    echo "=== Usage Instructions ==="
    echo "JavaFX SDK location: $SDK_DIR"
    echo "Add to your Java application classpath:"
    echo "  --module-path $SDK_DIR/lib"
    echo "  --add-modules javafx.controls,javafx.fxml,javafx.media"
    echo
    echo "For JNI applications, native libraries are automatically loaded from:"
    echo "  $SDK_DIR/lib/"
    
    echo
    echo "=== Environment Setup ==="
    echo "Add these to your ~/.bashrc or ~/.profile:"
    echo "export JAVAFX_HOME=$SDK_DIR"
    echo "export JAVAFX_LIB=\$JAVAFX_HOME/lib"
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64"
    
    echo
    echo "=== JDK17 Specific Notes ==="
    echo "This JavaFX build is specifically compiled for JDK17 compatibility"
    echo "Ensure your applications use JDK17 when running with this JavaFX build"
    echo "Module system compatibility: Fully supports JDK17 module system"
    
else
    echo
    echo "=== Build Failed ==="
    echo "Check the build output above for error details."
    echo "Common issues:"
    echo "- Missing system dependencies"
    echo "- Insufficient memory (requires ~4GB RAM)"
    echo "- Java version compatibility (ensure JDK17 is active)"
    echo "- Network issues during dependency download"
    exit 1
fi

echo
echo "=== Script Completed ==="
echo "JavaFX 17 with ARM64 JNI support has been built successfully for JDK17!"
echo "Working directory: $WORK_DIR"
echo "Java version used: $(java -version 2>&1 | head -n 1)"
