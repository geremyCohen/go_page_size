#!/usr/bin/env bash

# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential wget curl tar

# 2. Clean up existing files if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous TensorFlow custom JNI build..."
  sudo rm -f /usr/local/lib/libtensorflow_custom.so
  rm -rf native src pom.xml target
fi

## 2. Fetch TensorFlow C library (prebuilt for x86_64 or build from source on ARM)
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  # Prebuilt binary for x86_64
  if [ "$clean" = true ]; then
    echo "Removing previous TensorFlow C library..."
    sudo rm -f /usr/local/lib/libtensorflow.so*
    sudo rm -rf /usr/local/include/tensorflow
  fi
  URL="https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-2.15.0.tar.gz"
  echo "Downloading TensorFlow C library from $URL..."
  if ! curl -fSL "$URL" -o /tmp/libtensorflow.tar.gz; then
    echo "Error: failed to download TensorFlow C library"
    exit 1
  fi
  echo "Extracting to /usr/local..."
  sudo tar -C /usr/local -xzf /tmp/libtensorflow.tar.gz
  sudo ldconfig
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  # Build from source on ARM platforms
  if ! command -v bazel &>/dev/null; then
    echo "Installing Bazelisk for ARM64..."
    curl -fSL https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-arm64 -o bazel
    chmod +x bazel
    sudo mv bazel /usr/local/bin/bazel
  fi
  TF_SRC="$HOME/tensorflow"
  if [ ! -d "$TF_SRC" ]; then
    echo "Cloning TensorFlow source to $TF_SRC..."
    git clone https://github.com/tensorflow/tensorflow.git "$TF_SRC"
  fi
  cd "$TF_SRC"
  git checkout v2.15.0 || true
  echo "Building TensorFlow C library (this may take several minutes)..."
  bazel build -c opt //tensorflow:libtensorflow.so
  echo "Installing built libtensorflow.so..."
  sudo cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/
  echo "Installing TensorFlow C headers..."
  # Copy C API headers
  sudo mkdir -p /usr/local/include/tensorflow
  sudo cp -r tensorflow/c /usr/local/include/tensorflow/
  # Copy TSL C headers for status API
  sudo cp -r tensorflow/tsl /usr/local/include/
  cd - >/dev/null
  sudo ldconfig
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi
# verify headers
if [ ! -f /usr/local/include/tensorflow/c/c_api.h ]; then
  echo "Error: TensorFlow C headers not found under /usr/local/include/tensorflow/c"
  exit 1
fi

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

    public static native String tfHelloWorld();

    public static void main(String[] args) {
        System.out.println("TensorFlow Demo Starting...");
        String msg = tfHelloWorld();
        System.out.println("Native method returned: " + msg);

        // (Optional) Java API version retrieval skipped; using native TF C API version above

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