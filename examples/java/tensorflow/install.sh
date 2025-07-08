#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev python3-venv bazel-bootstrap

# 2. Clone TensorFlow
cd
git clone https://github.com/tensorflow/tensorflow.git ~/tensorflow
cd ~/tensorflow

# 3. Patch TensorFlow to add custom printf
# Find a core TensorFlow C++ file to patch
TF_CORE_SRC=~/tensorflow/tensorflow/core/framework/tensor.cc
if [ -f "$TF_CORE_SRC" ]; then
    echo "Patching $TF_CORE_SRC"
    # Add include for printf at the top
    sed -i '1i#include <cstdio>' "$TF_CORE_SRC"
    
    # Clean up any previous patches
    sed -i '/printf.*hello from custom tensorflow/d' "$TF_CORE_SRC"
    sed -i '/fflush(stdout);/d' "$TF_CORE_SRC"
    
    # Find Tensor constructor and add our custom print
    sed -i '/^Tensor::Tensor(DataType type, const TensorShape& shape)/,/^{$/ {
        /^{$/ a\    printf("hello from custom tensorflow\\n"); fflush(stdout);
    }' "$TF_CORE_SRC"
    
    # Verify the patch was applied
    if grep -q "hello from custom tensorflow" "$TF_CORE_SRC"; then
        echo "✓ Patch successfully applied"
        echo "Patch verification:"
        grep -A2 -B2 "hello from custom tensorflow" "$TF_CORE_SRC"
    else
        echo "✗ Patch may not have been applied correctly"
    fi
else
    echo "tensor.cc not found, trying alternative locations"
    find ~/tensorflow/tensorflow/core/ -name "*.cc" | head -5
fi

# 4. Build TensorFlow with Java bindings (force clean rebuild)
cd ~/tensorflow
rm -rf bazel-*
./configure
bazel build --config=opt //tensorflow/java:tensorflow //tensorflow/java:libtensorflow_jni

# 5. Copy TensorFlow Java bindings to system library path
sudo cp bazel-bin/tensorflow/java/libtensorflow_jni.so /usr/local/lib/
sudo ldconfig

# 6. Install TensorFlow Java jar locally into Maven repository
cd ~/tensorflow/bazel-bin/tensorflow/java
TF_JAR=$(ls tensorflow-*.jar 2>/dev/null | head -1)
if [ -n "$TF_JAR" ]; then
    # Extract version (use a fixed version for simplicity)
    TF_VERSION="2.15.0"
    echo "Installing TensorFlow JAR: $TF_JAR with version: $TF_VERSION"
    mvn install:install-file \
      -Dfile="$TF_JAR" \
      -DgroupId=org.tensorflow \
      -DartifactId=tensorflow-java-local \
      -Dversion="$TF_VERSION" \
      -Dpackaging=jar
    
    # Update POM with correct version
    cd ~/go_page_size/examples/java/tensorflow/
    sed -i "s/<version>2.15.0<\/version>/<version>$TF_VERSION<\/version>/" pom.xml
    
    # Copy JAR to project directory for direct classpath use
    cp ~/tensorflow/bazel-bin/tensorflow/java/"$TF_JAR" ./
else
    echo "TensorFlow JAR not found"
    ls -la ~/tensorflow/bazel-bin/tensorflow/java/
fi

# 7. Set JNI library visibility permanently
echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc && source ~/.bashrc

# 8. Navigate to project directory and compile
cd ~/go_page_size/examples/java/tensorflow/

# 9. Find the actual TensorFlow Java library name and update Java code
TF_LIB=$(ls /usr/local/lib/libtensorflow_jni.so 2>/dev/null | head -1)
if [ -n "$TF_LIB" ]; then
    echo "Found TensorFlow library: $TF_LIB"
    # Update Java code with actual library name
    LIB_NAME=$(basename "$TF_LIB")
    sed -i "s/libtensorflow_jni.so/$LIB_NAME/" src/main/java/com/example/TensorFlowDemo.java
    
    # Compile manually with javac
    mkdir -p target/classes
    TF_JAR_LOCAL=$(ls tensorflow-*.jar 2>/dev/null | head -1)
    javac -cp "$TF_JAR_LOCAL" -d target/classes src/main/java/com/example/TensorFlowDemo.java
else
    echo "TensorFlow library not found in /usr/local/lib/"
    ls -la /usr/local/lib/libtensorflow*
fi

# 10. Run the application with TensorFlow JAR in classpath
cd ~/go_page_size/examples/java/tensorflow/
TF_JAR_LOCAL=$(ls tensorflow-*.jar 2>/dev/null | head -1)
if [ -n "$TF_JAR_LOCAL" ]; then
    echo "TensorFlow JAR: $TF_JAR_LOCAL"
    java -cp "target/classes:$TF_JAR_LOCAL" com.example.TensorFlowDemo
else
    echo "TensorFlow JAR not found in current directory"
    ls -la *.jar
fi