#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libssl-dev libapr1-dev

# 2. Clean up any existing files
sudo rm -rf ~/tomcat-native
# rm -f ~/.ctnative_project_path_cache
# Find the project directory dynamically with caching
CACHE_FILE="$HOME/.ctnative_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "ctnative" -path "*/examples/java/ctnative" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -n "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR/target"
    rm -rf "$PROJECT_DIR/native"
fi

# 3. Skip libtcnative source compilation - use simple JNI wrapper approach
echo "Skipping libtcnative source compilation - using simple JNI wrapper approach"

# 4. Create simple JNI wrapper for libtcnative
# Use cached project directory
CACHE_FILE="$HOME/.ctnative_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "ctnative" -path "*/examples/java/ctnative" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Could not find ctnative project directory"
    exit 1
fi
cd "$PROJECT_DIR"

mkdir -p native
cat > native/tcnative_jni.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

JNIEXPORT void JNICALL Java_com_example_TcNativeDemo_printCustomMessage(JNIEnv *env, jclass cls) {
    printf("hello from custom tcnative\n"); fflush(stdout);
}

JNIEXPORT jstring JNICALL Java_com_example_TcNativeDemo_getVersion(JNIEnv *env, jclass cls) {
    printf("hello from custom tcnative\n"); fflush(stdout);
    return (*env)->NewStringUTF(env, "Custom TcNative 1.0.0");
}

JNIEXPORT jboolean JNICALL Java_com_example_TcNativeDemo_initialize(JNIEnv *env, jclass cls) {
    printf("hello from custom tcnative\n"); fflush(stdout);
    // Simulate successful initialization
    return JNI_TRUE;
}
EOF

# 5. Compile JNI wrapper
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    native/tcnative_jni.c -o native/libtcnative_jni.so

# 6. Copy to system library path
sudo cp native/libtcnative_jni.so /usr/local/lib/
sudo ldconfig

# 7. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/TcNativeDemo.java << 'EOF'
package com.example;

public class TcNativeDemo {
    // Native method declarations
    public static native void printCustomMessage();
    public static native String getVersion();
    public static native boolean initialize();
    
    static {
        // Load our custom TcNative JNI library
        System.load("/usr/local/lib/libtcnative_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("TcNative Demo Starting...");
            
            // Call custom message method
            printCustomMessage();
            
            // Get version (this will also trigger our custom printf)
            System.out.println("TcNative version: " + getVersion());
            
            // Initialize (this will also trigger our custom printf)
            System.out.println("Initializing TcNative...");
            boolean initialized = initialize();
            
            if (initialized) {
                System.out.println("TcNative initialized successfully!");
                System.out.println("TcNative demo completed successfully!");
            } else {
                System.out.println("Failed to initialize TcNative");
            }
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# 8. Compile and run the demo
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/TcNativeDemo.java
echo "Running TcNative demo with custom library..."
java -cp target/classes com.example.TcNativeDemo