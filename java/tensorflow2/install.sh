#!/usr/bin/env bash
set -e

#-------------------------------------------------------------------
# TensorFlow C API JNI Demo Installer for ARM64
# This script builds libtensorflow.so from source on ARM64 and
# compiles a JNI wrapper that calls TF_Version() via JNI.
#-------------------------------------------------------------------

# Toggle cleanup of previous builds (set to false to speed up incremental runs)
clean=true

# 1. Install system packages and build tools (skip if clean=false)
if [ "$clean" = true ]; then
  sudo apt update
  sudo apt install -y \
      openjdk-17-jdk \
      maven \
      git \
      cmake \
      build-essential \
      python3-dev \
      python3-pip \
      wget \
      curl \
      zip \
      zlib1g-dev \
      clang \
      apt-transport-https \
      gnupg

  # Ensure Bazel is available via Bazelisk (ARM64)
  export PATH="/usr/local/bin:$PATH"
  if ! command -v bazel &>/dev/null; then
    echo "Installing Bazelisk (Bazel launcher) for ARM64..."
    curl -fsSL https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-arm64 -o bazel
    chmod +x bazel
    sudo mv bazel /usr/local/bin/bazel
  fi
fi
    
# 2. Clean up previous artifacts if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous TensorFlow build and JNI artifacts..."
  rm -rf native src target tensorflow
  sudo rm -f /usr/local/lib/libtensorflow.so*
  sudo rm -f /usr/local/lib/libtensorflow_custom.so
  sudo rm -rf /usr/local/include/tensorflow /usr/local/include/tsl
fi

echo "Cloning TensorFlow v2.15.0 source..."
git clone --branch v2.15.0 https://github.com/tensorflow/tensorflow.git tensorflow
## 4. Clone TensorFlow source (v2.15.0) (skip if clean=false)
if [ "$clean" = true ]; then
  echo "Cloning TensorFlow v2.15.0 source..."
  git clone --branch v2.15.0 https://github.com/tensorflow/tensorflow.git tensorflow
else
  echo "Skipping clone (clean=false), assuming ./tensorflow exists"
fi
cd tensorflow
cd tensorflow

# 5. Patch denormal.cc to include <cstdint> for ARM64
echo "Patching denormal.cc to include <cstdint>..."
# TensorFlow path for denormal.cc under XLA third_party
sed -i '1i#include <cstdint>' third_party/xla/third_party/tsl/tsl/platform/denormal.cc

# 6. Configure TensorFlow build non-interactively
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

# 7. Build the TensorFlow C shared library (monolithic, using ld.bfd)
echo "Building libtensorflow.so (this may take many minutes)..."
bazel build -c opt \
    --config=monolithic \
    --copt=-mcmodel=large \
    --linkopt=-mcmodel=large \
    --linkopt=-fuse-ld=bfd \
    //tensorflow:libtensorflow.so

# 8. Install TensorFlow C library and headers
echo "Installing TensorFlow C library and headers to /usr/local..."
sudo cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/
sudo mkdir -p /usr/local/include/tensorflow
sudo cp -r tensorflow/c /usr/local/include/tensorflow/
sudo mkdir -p /usr/local/include/tsl
sudo cp -r tensorflow/tsl /usr/local/include/tsl/
cd ..
sudo ldconfig

# 9. Create JNI wrapper source invoking real TF C API
echo "Generating JNI wrapper source..."
mkdir -p native src/main/java/com/example target/classes
cat > native/tensorflow_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>
#include <tensorflow/c/c_api.h>

// Real call into TF_C_API: returns version string
JNIEXPORT jstring JNICALL Java_com_example_TensorFlowDemo_version(JNIEnv *env, jclass cls) {
    const char* ver = TF_Version();
    printf("Hello from TensorFlow C library! Version: %s\n", ver);
    fflush(stdout);
    return (*env)->NewStringUTF(env, ver);
}
EOF

# 10. Compile JNI shared library
echo "Compiling JNI shared library..."
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "Using JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC \
    -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I"/usr/local/include" \
    native/tensorflow_custom.c \
    -L"/usr/local/lib" -ltensorflow \
    -o native/libtensorflow_custom.so

# 11. Install JNI library
echo "Installing JNI library to /usr/local/lib..."
sudo cp native/libtensorflow_custom.so /usr/local/lib/
sudo ldconfig

# 12. Create Java demo source
echo "Generating Java demo source..."
mkdir -p src/main/java/com/example
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

# 13. Compile and run Java demo
echo "Compiling Java sources..."
javac -d target/classes src/main/java/com/example/TensorFlowDemo.java
echo "Running TensorFlow Demo with custom JNI library..."
java -cp target/classes com.example.TensorFlowDemo