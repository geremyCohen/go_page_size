#!/usr/bin/env bash
set -e

# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 1. Install system packages and build tools
sudo apt update
sudo apt install -y \
    openjdk-17-jdk maven git cmake build-essential python3-dev python3-pip \
    wget curl zip zlib1g-dev clang

# 2. Clean up previous artifacts if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous TensorFlow custom JNI build..."
  rm -rf native src target tensorflow
fi

# 3. Clone TensorFlow source (v2.15.0)
git clone --depth 1 --branch v2.15.0 https://github.com/tensorflow/tensorflow.git tensorflow
cd tensorflow

# 4. Configure build environment non-interactively
# 5. Configure TensorFlow build non-interactively
export PYTHON_BIN_PATH="$(which python3)"
export USE_DEFAULT_PYTHON_LIB_PATH=1
export TF_NEED_CUDA=0
export TF_NEED_ROCM=0
export TF_NEED_OPENCL=0
export TF_DOWNLOAD_CLANG=0
export TF_NEED_CLANG=0
export CC=gcc
export CXX=g++
export TF_SET_ANDROID_WORKSPACE=0
yes "" | ./configure

# 5. Build TensorFlow C shared library (monolithic, use ld.bfd)
echo "Building TensorFlow C library (ARM64)..."
bazel build -c opt \
    --config=monolithic \
    --linkopt=-fuse-ld=bfd \
    //tensorflow:libtensorflow.so

# 6. Install TensorFlow C library and headers
echo "Installing TensorFlow C API to /usr/local..."
sudo cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/
sudo mkdir -p /usr/local/include/tensorflow
sudo cp -r tensorflow/c /usr/local/include/tensorflow/
# Copy only the TSL C headers needed for tf_status.h
if [ -d tensorflow/tsl/c ]; then
  sudo mkdir -p /usr/local/include/tsl/c
  sudo cp tensorflow/tsl/c/*.h /usr/local/include/tsl/c/
fi
cd ..
sudo ldconfig

# 7. Create JNI wrapper invoking real TF_C_API
mkdir -p native src/main/java/com/example target/classes
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <tensorflow/c/c_api.h>

// Calls TF_Version() from the real TensorFlow C library
JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_version(JNIEnv *env, jclass cls) {
    const char* ver = TF_Version();
    printf("Hello from TensorFlow C library! Version: %s\n", ver);
    fflush(stdout);
    return (*env)->NewStringUTF(env, ver);
}
EOF

# 8. Compile JNI shared library
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "Using JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC \
    -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I/usr/local/include \
    native/tensorflow_custom.c \
    -L/usr/local/lib -ltensorflow \
    -o native/libtensorflow_custom.so

# 9. Install JNI library
sudo cp native/libtensorflow_custom.so /usr/local/lib/
sudo ldconfig

# 10. Create Java application source
cat > src/main/java/com/example/TensorFlowDemo.java << 'EOF'
package com.example;

public class TensorFlowDemo {
    static {
        String libPath = "/usr/local/lib/libtensorflow_custom.so";
        System.load(libPath);
        System.out.println("Loaded TensorFlow C library from: " + libPath);
    }

    public static native String version();

    public static void main(String[] args) {
        System.out.println("TensorFlow Demo Starting...");
        String ver = version();
        System.out.println("Native TensorFlow C library version: " + ver);
        System.out.println("TensorFlow Demo completed successfully!");
    }
}
EOF

# 11. Compile and run Java demo
echo "Compiling Java sources..."
javac -d target/classes src/main/java/com/example/TensorFlowDemo.java
echo "Running TensorFlow Demo with custom JNI library..."
java -cp target/classes com.example.TensorFlowDemo