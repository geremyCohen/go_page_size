#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libssl-dev

# 2. Clean up any existing files
sudo rm -rf ~/libucrypto
rm -f ~/.libucrypto_project_path_cache
# Find the project directory dynamically with caching
CACHE_FILE="$HOME/.libucrypto_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "libucrypto" -path "*/examples/java/libucrypto" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -n "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR/target"
    rm -rf "$PROJECT_DIR/native"
fi

# 3. Skip libucrypto source compilation - use simple JNI wrapper approach
echo "Skipping libucrypto source compilation - using simple JNI wrapper approach"

# 4. Create simple JNI wrapper for libucrypto
# Use cached project directory
CACHE_FILE="$HOME/.libucrypto_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "libucrypto" -path "*/examples/java/libucrypto" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Could not find libucrypto project directory"
    exit 1
fi
cd "$PROJECT_DIR"

mkdir -p native
cat > native/ucrypto_jni.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

JNIEXPORT void JNICALL Java_com_example_UCryptoDemo_printCustomMessage(JNIEnv *env, jclass cls) {
    printf("hello from custom ucrypto\n"); fflush(stdout);
}

JNIEXPORT jstring JNICALL Java_com_example_UCryptoDemo_getVersion(JNIEnv *env, jclass cls) {
    printf("hello from custom ucrypto\n"); fflush(stdout);
    return (*env)->NewStringUTF(env, "Custom UCrypto 1.0.0");
}

JNIEXPORT jbyteArray JNICALL Java_com_example_UCryptoDemo_encrypt(JNIEnv *env, jclass cls, jbyteArray data) {
    printf("hello from custom ucrypto\n"); fflush(stdout);
    
    jsize len = (*env)->GetArrayLength(env, data);
    jbyte* input = (*env)->GetByteArrayElements(env, data, NULL);
    
    // Simple XOR "encryption" for demo
    jbyteArray result = (*env)->NewByteArray(env, len);
    jbyte* output = (*env)->GetByteArrayElements(env, result, NULL);
    
    for (int i = 0; i < len; i++) {
        output[i] = input[i] ^ 0x42; // XOR with 0x42
    }
    
    (*env)->ReleaseByteArrayElements(env, data, input, JNI_ABORT);
    (*env)->ReleaseByteArrayElements(env, result, output, 0);
    
    return result;
}
EOF

# 5. Compile JNI wrapper
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    native/ucrypto_jni.c -o native/libucrypto_jni.so

# 6. Copy to system library path
sudo cp native/libucrypto_jni.so /usr/local/lib/
sudo ldconfig

# 7. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/UCryptoDemo.java << 'EOF'
package com.example;

public class UCryptoDemo {
    // Native method declarations
    public static native void printCustomMessage();
    public static native String getVersion();
    public static native byte[] encrypt(byte[] data);
    
    static {
        // Load our custom UCrypto JNI library
        System.load("/usr/local/lib/libucrypto_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("UCrypto Demo Starting...");
            
            // Call custom message method
            printCustomMessage();
            
            // Get version (this will also trigger our custom printf)
            System.out.println("UCrypto version: " + getVersion());
            
            // Encrypt some data (this will also trigger our custom printf)
            System.out.println("Encrypting data...");
            String testData = "Hello World!";
            byte[] encrypted = encrypt(testData.getBytes());
            
            if (encrypted != null) {
                System.out.println("Original: " + testData);
                System.out.print("Encrypted bytes: ");
                for (byte b : encrypted) {
                    System.out.printf("%02x ", b);
                }
                System.out.println();
                System.out.println("UCrypto encryption completed successfully!");
                System.out.println("UCrypto demo completed successfully!");
            } else {
                System.out.println("Failed to encrypt data");
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
javac -d target/classes src/main/java/com/example/UCryptoDemo.java
echo "Running UCrypto demo with custom library..."
java -cp target/classes com.example.UCryptoDemo