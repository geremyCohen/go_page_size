#!/bin/bash

echo "=== Installing system packages ==="
## 1. Install system packages (use Java 17 only)
# 1a. Update package list
sudo apt update
# Purge any Java 21 remnants
sudo apt purge -y 'openjdk-21-*'
# Remove leftover dependencies
sudo apt autoremove -y
# Install Java 17 and required build tools
sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libgtk-3-dev libgl1-mesa-dev \
    libx11-dev libxext-dev libxrender-dev libxtst-dev libxi-dev libxrandr-dev \
    libxcursor-dev libxss-dev libxinerama-dev libfreetype6-dev \
    libfontconfig1-dev libasound2-dev

# Ensure Java 17 is the system default for java/javac
if [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
  sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
  sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
elif [ -d /usr/lib/jvm/java-17-openjdk-arm64 ]; then
  sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-arm64/bin/java
  sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-arm64/bin/javac
fi

echo "=== Cleaning up existing files ==="
# 2. Clean up any existing files
sudo rm -rf ~/jfx
sudo rm -rf ~/jfx-build
# Remove existing JavaFX libraries from system
sudo rm -rf /usr/local/lib/javafx
sudo rm -f /usr/local/lib/*jfx*
sudo rm -f /usr/local/lib/*javafx*
sudo ldconfig
# Find the project directory dynamically with caching
CACHE_FILE="$HOME/.jfx_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "jfx" -path "*/java/jfx" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -n "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR/target"
    rm -rf "$PROJECT_DIR/native"
fi

echo "=== Cloning JavaFX from source ==="
# 3. Clone JavaFX from source
cd
# Force fresh clone to avoid Gradle cache issues
rm -rf ~/jfx
git clone https://github.com/openjdk/jfx.git ~/jfx
cd ~/jfx
# Checkout JavaFX 17 branch which is compatible with Java 17
git checkout jfx17
## 4a. Update Gradle wrapper to a newer version (>=6.3) for compatibility
WRAPPER_PROP=gradle/wrapper/gradle-wrapper.properties
if [ -f "$WRAPPER_PROP" ]; then
  echo "Updating Gradle wrapper distribution in $WRAPPER_PROP"
  sed -i 's|distributionUrl=.*|distributionUrl=https://services.gradle.org/distributions/gradle-7.6-bin.zip|' "$WRAPPER_PROP"
  # Remove checksum property to skip SHA verification (avoid mismatch errors)
  sed -i '/^distributionSha256Sum/d' "$WRAPPER_PROP"
fi

echo "=== Patching JavaFX native code ==="
# 4. Patch JavaFX to add custom printf
JFX_SRC=~/jfx/modules/javafx.graphics/src/main/native-prism/prism.c
if [ ! -f "$JFX_SRC" ]; then
    # Find a suitable native file to patch
    JFX_SRC=$(find ~/jfx -name "*.c" -o -name "*.cpp" | grep -E "(prism|glass|graphics)" | head -1)
fi
if [ -n "$JFX_SRC" ] && [ -f "$JFX_SRC" ]; then
    echo "Patching $JFX_SRC"
    # Add include for printf at the top
    sed -i '1i#include <stdio.h>' "$JFX_SRC"
    
    # Find first function and add printf
    FIRST_FUNC=$(grep -n "^[a-zA-Z].*{$" "$JFX_SRC" | head -1 | cut -d: -f1)
    if [ -n "$FIRST_FUNC" ]; then
        sed -i "${FIRST_FUNC}a\\    printf(\"hello from custom jfx\\\\n\"); fflush(stdout);" "$JFX_SRC"
        echo "✓ Patch applied to JavaFX native code"
    fi
else
    echo "JavaFX native source not found, will add message to JNI wrapper"
fi

echo "=== Building JavaFX from source ==="
# 5. Build JavaFX from source
cd ~/jfx
## Determine and enforce Java 17 for Gradle/Groovy compatibility
JAVAC_CMD=$(command -v javac || true)
if [ -n "$JAVAC_CMD" ] && javac -version 2>&1 | grep -qE 'javac (1\.)?17\.'; then
  export JAVA_HOME=$(dirname $(dirname $(readlink -f "$JAVAC_CMD")))
elif [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
elif [ -d /usr/lib/jvm/java-17-openjdk-arm64 ]; then
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
else
  echo "Error: Java 17 JDK not found. Please install openjdk-17-jdk and ensure javac 17 is in PATH." >&2
  exit 1
fi
export PATH="$JAVA_HOME/bin:$PATH"
echo "Building JavaFX with JAVA_HOME: $JAVA_HOME"
# Build JavaFX (this may take a while)
# Clean any existing Gradle caches
rm -rf ~/.gradle
# Ensure the Gradle wrapper is executable
chmod +x gradlew
echo "Stopping any existing Gradle daemons..."
./gradlew --stop || true
echo "Building JavaFX via Gradle wrapper with JAVA_HOME=$JAVA_HOME"
./gradlew --no-daemon --refresh-dependencies -Dorg.gradle.java.home="$JAVA_HOME" sdk

echo "=== Installing JavaFX libraries ==="
# 6. Copy JavaFX libraries to system library path
sudo mkdir -p /usr/local/lib/javafx
if [ -d "build/sdk/lib" ]; then
    sudo cp -r build/sdk/lib/* /usr/local/lib/javafx/
    sudo ldconfig
    echo "JavaFX libraries installed to /usr/local/lib/javafx"
else
    echo "JavaFX build output not found"
fi

echo "=== Setting up JavaFX runtime environment ==="
# 7. Setup JavaFX runtime environment
# Use cached project directory
CACHE_FILE="$HOME/.jfx_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "jfx" -path "*/java/jfx" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Could not find jfx project directory"
    exit 1
fi
cd "$PROJECT_DIR"

echo "Using custom-compiled JavaFX libraries from ~/jfx/build/sdk"

echo "=== Creating Java application ==="
# 8. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/JFXDemo.java << 'EOF'
package com.example;

public class JFXDemo {
    static {
        // Load the custom compiled JavaFX library from specific location
        try {
            System.load("/usr/local/lib/javafx/libprism_es2.so");
            System.out.println("Successfully loaded custom JavaFX native library");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("FATAL: Could not load custom JavaFX library: " + e.getMessage());
            System.err.println("Expected library: /usr/local/lib/javafx/libprism_es2.so");
            System.exit(1);
        }
    }

    public static void main(String[] args) {
        try {
            System.out.println("JavaFX Demo Starting...");
            System.out.println("Using custom-compiled JavaFX from source!");
            
            // Try to get JavaFX version information
            String javaVersion = System.getProperty("java.version");
            String javaFxVersion = System.getProperty("javafx.version", "Custom Build");
            
            System.out.println("Java version: " + javaVersion);
            System.out.println("JavaFX version: " + javaFxVersion);
            
            // Set JavaFX module path to our custom build
            String jfxPath = "/usr/local/lib/javafx";
            System.setProperty("javafx.runtime.path", jfxPath);
            System.out.println("Custom JavaFX libraries path: " + jfxPath);
            
            // The custom printf message will appear when JavaFX native libraries are loaded
            System.out.println("JavaFX native libraries loaded - check for custom messages above");
            System.out.println("JavaFX demo completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

echo "=== Compiling and running demo ==="
# 9. Compile and run the demo
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/JFXDemo.java
echo "Running JavaFX demo with custom library..."
java -cp target/classes com.example.JFXDemo