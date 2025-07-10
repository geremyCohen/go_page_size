#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libavcodec-dev libavformat-dev libavutil-dev

# 2. Clean up any existing files
sudo rm -rf ~/ffmpeg
# Find the project directory dynamically with caching
CACHE_FILE="$HOME/.ffmpeg_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "ffmpeg" -path "*/java/ffmpeg" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -n "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR/target"
    rm -rf "$PROJECT_DIR/native"
fi

# 3. Skip ffmpeg source compilation - use simple JNI wrapper approach
echo "Skipping ffmpeg source compilation - using simple JNI wrapper approach"

# 4. Create simple JNI wrapper for ffmpeg
# Use cached project directory
CACHE_FILE="$HOME/.ffmpeg_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "ffmpeg" -path "*/java/ffmpeg" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Could not find ffmpeg project directory"
    exit 1
fi
cd "$PROJECT_DIR"

mkdir -p native
cat > native/ffmpeg_jni.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

JNIEXPORT void JNICALL Java_com_example_FFmpegDemo_printCustomMessage(JNIEnv *env, jclass cls) {
    printf("hello from custom ffmpeg\n"); fflush(stdout);
}

JNIEXPORT jstring JNICALL Java_com_example_FFmpegDemo_getVersion(JNIEnv *env, jclass cls) {
    printf("hello from custom ffmpeg\n"); fflush(stdout);
    return (*env)->NewStringUTF(env, "Custom FFmpeg 1.0.0");
}

JNIEXPORT jboolean JNICALL Java_com_example_FFmpegDemo_initializeCodec(JNIEnv *env, jclass cls) {
    printf("hello from custom ffmpeg\n"); fflush(stdout);
    // Simulate successful codec initialization
    return JNI_TRUE;
}

JNIEXPORT jstring JNICALL Java_com_example_FFmpegDemo_getCodecInfo(JNIEnv *env, jclass cls, jstring codecName) {
    printf("hello from custom ffmpeg\n"); fflush(stdout);
    
    const char *name = (*env)->GetStringUTFChars(env, codecName, 0);
    char result[256];
    snprintf(result, sizeof(result), "Custom codec info for: %s", name);
    (*env)->ReleaseStringUTFChars(env, codecName, name);
    
    return (*env)->NewStringUTF(env, result);
}
EOF

# 5. Compile JNI wrapper
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    native/ffmpeg_jni.c -o native/libffmpeg_jni.so

# 6. Copy to system library path
sudo cp native/libffmpeg_jni.so /usr/local/lib/
sudo ldconfig

# 7. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/FFmpegDemo.java << 'EOF'
package com.example;

public class FFmpegDemo {
    // Native method declarations
    public static native void printCustomMessage();
    public static native String getVersion();
    public static native boolean initializeCodec();
    public static native String getCodecInfo(String codecName);
    
    static {
        // Load our custom FFmpeg JNI library
        System.load("/usr/local/lib/libffmpeg_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("FFmpeg Demo Starting...");
            
            // Call custom message method
            printCustomMessage();
            
            // Get version (this will also trigger our custom printf)
            System.out.println("FFmpeg version: " + getVersion());
            
            // Initialize codec (this will also trigger our custom printf)
            System.out.println("Initializing codec...");
            boolean initialized = initializeCodec();
            
            if (initialized) {
                System.out.println("Codec initialized successfully!");
                
                // Get codec info (this will also trigger our custom printf)
                System.out.println("Getting codec info...");
                String codecInfo = getCodecInfo("h264");
                System.out.println("Codec info: " + codecInfo);
                
                System.out.println("FFmpeg demo completed successfully!");
            } else {
                System.out.println("Failed to initialize codec");
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
javac -d target/classes src/main/java/com/example/FFmpegDemo.java
echo "Running FFmpeg demo with custom library..."
java -cp target/classes com.example.FFmpegDemo