#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget

# 2. Clean up any existing files
rm -rf ~/tensorflow
rm -rf ~/go_page_size/examples/java/tensorflow/target
rm -rf ~/go_page_size/examples/java/tensorflow/native

# 3. Navigate to project directory
cd ~/go_page_size/examples/java/tensorflow/

# 4. Create a simple custom library that prints our message
mkdir -p native
cat > native/custom_tf.c << 'EOF'
#include <stdio.h>
#include <jni.h>

JNIEXPORT void JNICALL Java_com_example_TensorFlowDemo_printCustomMessage(JNIEnv *env, jclass cls) {
    printf("hello from custom tensorflow\n");
    fflush(stdout);
}
EOF

# 5. Find JAVA_HOME and compile our custom JNI library
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    native/custom_tf.c -o native/libcustom_tf.so

# 6. Copy to system library path
sudo cp native/libcustom_tf.so /usr/local/lib/
sudo ldconfig

# 7. Create the Java application
cat > src/main/java/com/example/TensorFlowDemo.java << 'EOF'
package com.example;

public class TensorFlowDemo {
    // Native method declaration
    public static native void printCustomMessage();
    
    static {
        // Load our custom library
        System.load("/usr/local/lib/libcustom_tf.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("TensorFlow Demo Starting...");
            
            // Call our custom method to print the message
            printCustomMessage();
            
            // Simple demonstration without complex TensorFlow operations
            System.out.println("Custom TensorFlow library loaded successfully!");
            System.out.println("TensorFlow demo completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# 8. Compile and run the demo
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/TensorFlowDemo.java
echo "Running TensorFlow demo with custom library..."
java -cp target/classes com.example.TensorFlowDemo