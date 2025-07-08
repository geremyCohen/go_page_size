#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget

# 2. Download pre-built TensorFlow Java binaries
cd ~/go_page_size/examples/java/tensorflow/
mkdir -p libs
cd libs

# Download TensorFlow Java JAR and native library
wget https://repo1.maven.org/maven2/org/tensorflow/tensorflow-core-platform/0.4.0/tensorflow-core-platform-0.4.0.jar
wget https://repo1.maven.org/maven2/org/tensorflow/libtensorflow/2.10.0/libtensorflow-2.10.0.jar
wget https://repo1.maven.org/maven2/org/tensorflow/libtensorflow_jni/2.10.0/libtensorflow_jni-2.10.0.jar

# 3. Clone TensorFlow source for patching (but won't build it)
cd
rm -rf ~/tensorflow
git clone --branch v2.10.0 https://github.com/tensorflow/tensorflow.git ~/tensorflow
cd ~/tensorflow

# 4. Patch TensorFlow source and build just the C++ library
TF_CORE_SRC=~/tensorflow/tensorflow/core/framework/tensor.cc
if [ -f "$TF_CORE_SRC" ]; then
    echo "Patching $TF_CORE_SRC"
    # Add include for printf at the top
    sed -i '1i#include <cstdio>' "$TF_CORE_SRC"
    
    # Clean up any previous patches
    sed -i '/printf.*hello from custom tensorflow/d' "$TF_CORE_SRC"
    sed -i '/fflush(stdout);/d' "$TF_CORE_SRC"
    
    # Try to find any function definition and patch it
    FIRST_FUNC=$(grep -n "^[a-zA-Z].*::" "$TF_CORE_SRC" | head -1 | cut -d: -f1)
    if [ -n "$FIRST_FUNC" ]; then
        echo "Found function at line $FIRST_FUNC"
        sed -i "${FIRST_FUNC}a\\    printf(\"hello from custom tensorflow\\\\n\"); fflush(stdout);" "$TF_CORE_SRC"
    fi
    
    # Verify the patch was applied
    if grep -q "hello from custom tensorflow" "$TF_CORE_SRC"; then
        echo "✓ Patch successfully applied"
        echo "Patch verification:"
        grep -A2 -B2 "hello from custom tensorflow" "$TF_CORE_SRC"
    else
        echo "✗ Patch still failed"
    fi
fi

# 5. Build minimal TensorFlow C++ library with CMake (simpler than Bazel)
cd ~/tensorflow
mkdir -p build && cd build
cmake -DTENSORFLOW_BUILD_SHARED_LIBS=ON \
      -DTENSORFLOW_BUILD_CC_EXAMPLE=OFF \
      -DTENSORFLOW_BUILD_PYTHON_BINDINGS=OFF \
      ../tensorflow/lite/tools/cmake/
make -j$(nproc)

# Copy our custom library
sudo cp libtensorflow-lite.so /usr/local/lib/libtensorflow_custom.so
sudo ldconfig

# 6. Navigate to project directory and set up
cd ~/go_page_size/examples/java/tensorflow/

# 7. Update Java code to use our custom library
sed -i 's|libtensorflow_jni.so|libtensorflow_custom.so|' src/main/java/com/example/TensorFlowDemo.java

# 8. Compile with downloaded JAR
mkdir -p target/classes
TF_JAR=$(ls libs/tensorflow-core-platform-*.jar 2>/dev/null | head -1)
if [ -n "$TF_JAR" ]; then
    javac -cp "$TF_JAR" -d target/classes src/main/java/com/example/TensorFlowDemo.java
    echo "TensorFlow JAR: $TF_JAR"
    java -cp "target/classes:$TF_JAR" com.example.TensorFlowDemo
else
    echo "TensorFlow JAR not found"
    ls -la libs/
fi