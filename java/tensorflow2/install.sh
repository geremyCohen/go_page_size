#!/usr/bin/env bash
set -e

# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 1. Install system packages and build tools
sudo apt update
sudo apt install -y \
    openjdk-17-jdk git cmake build-essential python3-dev python3-pip wget curl zip zlib1g-dev

# 2. Clean up previous artifacts if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous TensorFlow custom JNI build..."
  sudo rm -f /usr/local/lib/libtensorflow.so*
  sudo rm -f /usr/local/lib/libtensorflow_custom.so
  sudo rm -rf /usr/local/include/tensorflow /usr/local/include/tsl
  rm -rf native src target tensorflow
fi

# 3. Install Bazelisk (Bazel launcher) if Bazel is missing
if ! command -v bazel &>/dev/null; then
  echo "Installing Bazelisk for ARM64..."
  curl -fsSL \
    https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-arm64 \
    -o bazel
  chmod +x bazel
  sudo mv bazel /usr/local/bin/bazel
fi

# 4. Clone TensorFlow source and checkout the 2.15.0 tag
git clone --depth 1 --branch v2.15.0 https://github.com/tensorflow/tensorflow.git tensorflow
cd tensorflow

# 5. Configure TensorFlow build non-interactively
export PYTHON_BIN_PATH="$(which python3)";
export USE_DEFAULT_PYTHON_LIB_PATH=1;
export TF_NEED_CUDA=0;
export TF_DOWNLOAD_CLANG=0;
export TF_NEED_ROCM=0;
export TF_SET_ANDROID_WORKSPACE=0;
yes "" | ./configure

# 6. Build the TensorFlow C shared library with monolithic config
echo "Building TensorFlow C library (ARM64) ..."
bazel build -c opt --config=monolithic //tensorflow:libtensorflow.so

# 7. Install TensorFlow C library and headers
echo "Installing TensorFlow C library and headers to /usr/local/..."
sudo cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/
sudo mkdir -p /usr/local/include/tensorflow
sudo cp -r tensorflow/c /usr/local/include/tensorflow/
sudo cp -r tensorflow/tsl /usr/local/include/
cd ..
sudo ldconfig

# 8. Compile custom JNI wrapper
mkdir -p native src/main/java/com/example target/classes
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <tensorflow/c/c_api.h>

// Returns the TensorFlow C library version and prints a native-side message
JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_version(JNIEnv *env, jclass cls) {
    const char* ver = TF_Version();
    printf("Hello from TensorFlow C library! Version: %s\n", ver);
    fflush(stdout);
    return (*env)->NewStringUTF(env, ver);
}
EOF

# 9. Compile the JNI shared library
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "Using JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC \
    -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I/usr/local/include \
    native/tensorflow_custom.c \
    -L/usr/local/lib -ltensorflow \
    -o native/libtensorflow_custom.so

# 10. Install the JNI library
sudo cp native/libtensorflow_custom.so /usr/local/lib/
sudo ldconfig

# 11. Create Java application source
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/TensorFlowDemo.java << 'EOF'
package com.example;

public class TensorFlowDemo {
    static {
        String libPath = "/usr/local/lib/libtensorflow_custom.so";
        try {
            System.load(libPath);
            System.out.println("Loaded TensorFlow C library from: " + libPath);
        } catch (Throwable t) {
            t.printStackTrace();
            System.exit(1);
        }
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

# 12. Compile and run Java demo
echo "Compiling Java sources..."
javac -d target/classes src/main/java/com/example/TensorFlowDemo.java
echo "Running TensorFlow Demo with custom JNI library..."
java -cp target/classes com.example.TensorFlowDemo