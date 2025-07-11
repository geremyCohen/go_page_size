#!/usr/bin/env bash

# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential wget bazel

# 2. Clean up existing files if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous TensorFlow custom JNI build..."
  sudo rm -f /usr/local/lib/libtensorflow_custom.so
  rm -rf native src pom.xml target
fi

## 2. Clone & build TensorFlow C shared library
TF_SRC_DIR="$HOME/tensorflow"
if [ ! -d "$TF_SRC_DIR" ]; then
  echo "Cloning TensorFlow source into $TF_SRC_DIR..."
  git clone https://github.com/tensorflow/tensorflow.git "$TF_SRC_DIR"
fi
cd "$TF_SRC_DIR"
# Optional: checkout a specific version for reproducibility
git checkout v2.15.0 || true
echo "Building TensorFlow shared library... (this may take a while)"
bazel build --config=opt //tensorflow:libtensorflow.so
sudo cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/
sudo ldconfig
cd - >/dev/null

# 3. Compile custom JNI wrapper
mkdir -p native
# Create JNI wrapper invoking the TensorFlow C API
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <tensorflow/c/c_api.h>

JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_tfHelloWorld(JNIEnv *env, jclass cls) {
    printf("Hello from custom TensorFlow native library!\n"); fflush(stdout);
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
    -I"$TF_SRC_DIR" \
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

    public static native String tfHelloWorld();

    public static void main(String[] args) {
        System.out.println("TensorFlow Demo Starting...");
        String msg = tfHelloWorld();
        System.out.println("Native method returned: " + msg);

        // Print Java TensorFlow version via Java API
        try {
            String version = org.tensorflow.TensorFlow.version();
            System.out.println("Java TensorFlow version: " + version);
        } catch (Throwable t) {
            System.err.println("Warning: Unable to retrieve TensorFlow Java version: " + t.getMessage());
        }

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