#!/usr/bin/env bash
set -e

# Only toggle cleanup of JNI/Java artifacts
clean=true

# 1) Clean old JNI artifacts
echo "Cleaning JNI artifacts..."
rm -rf native src target
sudo rm -f /usr/local/lib/libtensorflow_custom.so

# 2) Verify TensorFlow C API is installed
if [ ! -f /usr/local/lib/libtensorflow.so ]; then
  echo "Error: libtensorflow.so not found in /usr/local/lib"
  echo "Please run the manual build steps to install the TensorFlow C API first."
  exit 1
fi
if [ ! -f /usr/local/include/tensorflow/c/c_api.h ]; then
  echo "Error: TensorFlow C headers not found in /usr/local/include/tensorflow"
  echo "Please run the manual build steps to install the TensorFlow C API first."
  exit 1
fi

# 3) Generate JNI wrapper source
mkdir -p native src/main/java/com/example target/classes
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <tensorflow/c/c_api.h>

JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_version(JNIEnv *env,
jclass cls) {
    const char* ver = TF_Version();
    printf("Hello from TensorFlow C library! Version: %s\n", ver);
    fflush(stdout);
    return (*env)->NewStringUTF(env, ver);
}
EOF

# 4) Compile JNI shared library
echo "Compiling JNI shared library..."
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
gcc -shared -fPIC \
    -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I"/usr/local/include" \
    native/tensorflow_custom.c \
    -L"/usr/local/lib" -ltensorflow \
    -o native/libtensorflow_custom.so

# 5) Install JNI library
echo "Installing JNI library into /usr/local/lib"
sudo cp native/libtensorflow_custom.so /usr/local/lib/
sudo ldconfig

# 6) Create Java demo source
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/TensorFlowDemo.java << 'EOF'
package com.example;

public class TensorFlowDemo {
    static {
        System.load("/usr/local/lib/libtensorflow_custom.so");
        System.out.println("Loaded TensorFlow C library.");
    }

    public static native String version();

    public static void main(String[] args) {
        System.out.println("TensorFlow Demo Starting...");
        String v = version();
        System.out.println("Native TF C library version: " + v);
        System.out.println("TensorFlow Demo completed successfully!");
    }
}
EOF

# 7) Compile & run
echo "Compiling Java sources..."
javac -d target/classes src/main/java/com/example/TensorFlowDemo.java
echo "Running demo..."
java -cp target/classes com.example.TensorFlowDemo