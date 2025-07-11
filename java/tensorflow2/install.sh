#!/usr/bin/env bash

# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential wget curl tar libtensorflow-c-dev

# 2. Clean up existing files if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous TensorFlow custom JNI build..."
  sudo rm -f /usr/local/lib/libtensorflow_custom.so
  rm -rf native src pom.xml target
fi

## 2. Verify TensorFlow C library headers and lib from package
if [ ! -f /usr/include/tensorflow/c/c_api.h ]; then
  echo "Error: TensorFlow C headers not found; please install libtensorflow-c-dev"
  exit 1
fi
if [ ! -f /usr/lib/libtensorflow.so ]; then
  echo "Error: TensorFlow C library not found; please install libtensorflow-c-dev"
  exit 1
fi

# 3. Compile custom JNI wrapper
mkdir -p native
# Create JNI wrapper invoking the TensorFlow C API
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <tensorflow/c/c_api.h>

// Returns the TensorFlow C library version
JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_version(JNIEnv *env, jclass cls) {
    const char* ver = TF_Version();
    return (*env)->NewStringUTF(env, ver);
}
EOF

# 4. Determine JAVA_HOME
JAVA_HOME=$(readlink -f /usr/bin/java | sed 's:/bin/java::')
echo "Using JAVA_HOME: $JAVA_HOME"

# 5. Compile the JNI shared library, linking against TensorFlow C library
gcc -shared -fPIC \
    -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I/usr/local/include \
    native/tensorflow_custom.c \
    -L/usr/local/lib -ltensorflow -o native/libtensorflow_custom.so

# 4. Install the native library
sudo cp native/libtensorflow_custom.so /usr/local/lib/
sudo ldconfig

# 5. Create Java application source
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/TensorFlowDemo.java << 'EOF'
package com.example;

public class TensorFlowDemo {
    static {
        String libPath = "/usr/local/lib/libtensorflow_custom.so";
        try {
            System.load(libPath);
            System.out.println("Loaded custom TensorFlow library from: " + libPath);
        } catch (Throwable t) {
            System.err.println("Failed to load custom TensorFlow library: " + t.getMessage());
            t.printStackTrace();
            System.exit(1);
        }
    }
    // Native method to return the TensorFlow C library version
    public static native String version();

    public static void main(String[] args) {
        System.out.println("TensorFlow Demo Starting...");
        String ver = version();
        System.out.println("Native TensorFlow C library version: " + ver);

        System.out.println("TensorFlow Demo completed successfully!");
    }
}
EOF

# 6. Compile Java sources and run the demo
echo "Compiling Java sources..."
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/TensorFlowDemo.java
echo "Running TensorFlow Demo with custom JNI library..."
java -cp target/classes com.example.TensorFlowDemo