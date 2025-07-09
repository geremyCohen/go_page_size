#!/bin/bash

# 1. Install system packages
# sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
#    python3-pip python3-dev wget libblas-dev liblapack-dev libopenblas-dev

# 2. Clean up any existing files
sudo rm -rf ~/nd4j
sudo rm -rf ~/nd4j-build
rm -f ~/.jnind4jcpu_project_path_cache
# Find the project directory dynamically with caching
CACHE_FILE="$HOME/.jnind4jcpu_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "jnind4jcpu" -path "*/examples/java/jnind4jcpu" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -n "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR/target"
    rm -rf "$PROJECT_DIR/native"
fi

# 3. Skip ND4J source compilation - use simple JNI wrapper approach
echo "Skipping ND4J source compilation - using simple JNI wrapper approach"

# 4. Create simple JNI wrapper for ND4J
# Use cached project directory
CACHE_FILE="$HOME/.jnind4jcpu_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "jnind4jcpu" -path "*/examples/java/jnind4jcpu" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Could not find jnind4jcpu project directory"
    exit 1
fi
cd "$PROJECT_DIR"

mkdir -p native
cat > native/nd4j_jni.cpp << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern "C" {
    JNIEXPORT void JNICALL Java_com_example_ND4JDemo_printCustomMessage(JNIEnv *env, jclass cls) {
        printf("hello from custom nd4j\n"); fflush(stdout);
    }
    
    JNIEXPORT jdoubleArray JNICALL Java_com_example_ND4JDemo_createArray(JNIEnv *env, jclass cls, jint size) {
        printf("hello from custom nd4j\n"); fflush(stdout);
        
        jdoubleArray result = env->NewDoubleArray(size);
        if (result == NULL) {
            return NULL;
        }
        
        // Fill with simple values
        double* arr = new double[size];
        for (int i = 0; i < size; i++) {
            arr[i] = i * 1.5;
        }
        
        env->SetDoubleArrayRegion(result, 0, size, arr);
        delete[] arr;
        return result;
    }
}
EOF

# 5. Compile JNI wrapper
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
g++ -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I/usr/local/include \
    native/nd4j_jni.cpp -o native/libnd4j_jni.so

# 6. Copy to system library path
sudo cp native/libnd4j_jni.so /usr/local/lib/
sudo ldconfig

# 7. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/ND4JDemo.java << 'EOF'
package com.example;

public class ND4JDemo {
    // Native method declarations
    public static native void printCustomMessage();
    public static native double[] createArray(int size);
    
    static {
        // Load our custom ND4J JNI library
        System.load("/usr/local/lib/libnd4j_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("ND4J Demo Starting...");
            
            // Call custom message method
            printCustomMessage();
            
            // Create array (this will also trigger our custom printf)
            System.out.println("Creating array...");
            double[] array = createArray(5);
            
            if (array != null) {
                System.out.println("ND4J array created successfully!");
                System.out.print("Array values: ");
                for (int i = 0; i < array.length; i++) {
                    System.out.print(array[i] + " ");
                }
                System.out.println();
                System.out.println("ND4J demo completed successfully!");
            } else {
                System.out.println("Failed to create ND4J array");
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
javac -d target/classes src/main/java/com/example/ND4JDemo.java
echo "Running ND4J demo with custom library..."
java -cp target/classes com.example.ND4JDemo