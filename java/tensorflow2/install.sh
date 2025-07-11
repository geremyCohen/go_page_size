#!/usr/bin/env bash
set -e

# TensorFlow C API JNI Demo Installer for ARM64
# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 0. Verify required commands
for cmd in bazel clang java gcc git python3; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: '$cmd' command not found. Please install it before running this script."
    exit 1
  fi
done

# 1. Clean up previous artifacts if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous build artifacts..."
  rm -rf native src target tensorflow
  sudo rm -f /usr/local/lib/libtensorflow.so*
  sudo rm -f /usr/local/lib/libtensorflow_custom.so
  sudo rm -rf /usr/local/include/tensorflow /usr/local/include/tsl
fi

# 2. Clone TensorFlow source (v2.15.0)
echo "Cloning TensorFlow v2.15.0 source..."
git clone --depth 1 --branch v2.15.0 https://github.com/tensorflow/tensorflow.git tensorflow
cd tensorflow

# 3. Patch denormal.cc to include <cstdint> for ARM64 build
echo "Patching 'tsl/platform/denormal.cc' to include <cstdint>..."
sed -i '1i#include <cstdint>' tsl/platform/denormal.cc

# 4. Configure TensorFlow build non-interactively
echo "Configuring TensorFlow build..."
export PYTHON_BIN_PATH="$(which python3)"
export USE_DEFAULT_PYTHON_LIB_PATH=1
export TF_NEED_CUDA=0
export TF_DOWNLOAD_CLANG=0
export TF_NEED_CLANG=0
export TF_NEED_ROCM=0
export TF_NEED_OPENCL=0
export TF_SET_ANDROID_WORKSPACE=0
yes "" | ./configure

# 5. Build TensorFlow C shared library (monolithic)
echo "Building libtensorflow.so (this may take many minutes)..."
bazel build -c opt --config=monolithic //tensorflow:libtensorflow.so

# 6. Install TensorFlow C library and headers
echo "Installing TensorFlow C library and headers to /usr/local..."
sudo cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/
sudo mkdir -p /usr/local/include/tensorflow
sudo cp -r tensorflow/c /usr/local/include/tensorflow/
sudo mkdir -p /usr/local/include/tsl
sudo cp -r tensorflow/tsl /usr/local/include/tsl/
cd ..
sudo ldconfig

# 7. Generate JNI wrapper source
echo "Generating JNI wrapper source..."
mkdir -p native src/main/java/com/example target/classes
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <tensorflow/c/c_api.h>

// Calls TF_Version() from libtensorflow.so
JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_version(JNIEnv *env, jclass cls) {
    const char* ver = TF_Version();
    printf("Hello from TensorFlow C library! Version: %s\n", ver);
    fflush(stdout);
    return (*env)->NewStringUTF(env, ver);
}
EOF

# 8. Compile JNI shared library
echo "Compiling JNI shared library..."
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC \
    -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I"/usr/local/include" \
    native/tensorflow_custom.c \
    -L"/usr/local/lib" -ltensorflow \
    -o native/libtensorflow_custom.so

# 9. Install JNI library
echo "Installing JNI library to /usr/local/lib..."
sudo cp native/libtensorflow_custom.so /usr/local/lib/
sudo ldconfig

# 10. Create Java application source
echo "Generating Java demo source..."
cat > src/main/java/com/example/TensorFlowDemo.java << 'EOF'
package com.example;

public class TensorFlowDemo {
    static {
        String lib = "/usr/local/lib/libtensorflow_custom.so";
        System.load(lib);
        System.out.println("Loaded TensorFlow C library from: " + lib);
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