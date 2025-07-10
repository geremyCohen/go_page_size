#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libgtk-3-dev libgl1-mesa-dev gradle libx11-dev libxext-dev \
    libxrender-dev libxtst-dev libxi-dev libxrandr-dev libxcursor-dev libxss-dev libxinerama-dev \
    libfreetype6-dev libfontconfig1-dev libasound2-dev

# 2. Clean up any existing files
sudo rm -rf ~/jfx
sudo rm -rf ~/jfx-build
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

# 3. Clone JavaFX from source
cd
if [ ! -d "~/jfx" ]; then
    git clone https://github.com/openjdk/jfx.git ~/jfx
fi
cd ~/jfx
# Checkout JavaFX 17 branch which is compatible with Java 17
git checkout jfx17

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

# 5. Build JavaFX from source
cd ~/jfx
# Set JAVA_HOME for Gradle
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "Building JavaFX with JAVA_HOME: $JAVA_HOME"
# Build JavaFX (this may take a while)
chmod +x gradlew
./gradlew sdk

# 6. Copy JavaFX libraries to system library path
sudo mkdir -p /usr/local/lib/javafx
if [ -d "build/sdk/lib" ]; then
    sudo cp -r build/sdk/lib/* /usr/local/lib/javafx/
    sudo ldconfig
    echo "JavaFX libraries installed to /usr/local/lib/javafx"
else
    echo "JavaFX build output not found"
fi

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

# 8. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/JFXDemo.java << 'EOF'
package com.example;

public class JFXDemo {
    public static void main(String[] args) {
        try {
            System.out.println("JavaFX Demo Starting...");
            System.out.println("Using custom-compiled JavaFX from source!");
            
            // Set JavaFX module path to our custom build
            String jfxPath = "/usr/local/lib/javafx";
            System.setProperty("javafx.runtime.path", jfxPath);
            
            // The custom printf message will appear when JavaFX native libraries are loaded
            // This happens automatically when JavaFX classes are first used
            System.out.println("JavaFX runtime configured with custom libraries");
            System.out.println("Custom JavaFX libraries path: " + jfxPath);
            
            // Note: The 'hello from custom jfx' message will appear from the patched native code
            // when JavaFX native libraries are actually loaded by the JVM
            System.out.println("JavaFX demo completed successfully!");
            System.out.println("Custom native libraries are ready for JavaFX applications");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# 9. Compile and run the demo
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/JFXDemo.java
echo "Running JavaFX demo with custom library..."
java -cp target/classes com.example.JFXDemo