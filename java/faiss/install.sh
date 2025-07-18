#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libblas-dev liblapack-dev swig libgflags-dev

# 2. Clean up any existing files
sudo rm -rf ~/faiss
rm -rf ~/go_page_size/examples/java/faiss/target
rm -rf ~/go_page_size/examples/java/faiss/native

# 3. Clone Faiss from source
cd
if [ ! -d "~/faiss" ]; then
    git clone https://github.com/facebookresearch/faiss.git ~/faiss
fi
cd ~/faiss

# 4. Skip patching Faiss source - we'll add the message to JNI wrapper instead
echo "Skipping Faiss source patching - using JNI wrapper approach"

# 5. Build Faiss with Java bindings
cd ~/faiss
mkdir -p build && cd build
cmake -DFAISS_ENABLE_PYTHON=OFF \
      -DFAISS_ENABLE_GPU=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DFAISS_ENABLE_C_API=OFF \
      -DBUILD_TESTING=OFF \
      ..
make -j$(nproc)
sudo make install
sudo ldconfig

# 6. Copy Faiss library to system library path
sudo cp ~/faiss/build/faiss/libfaiss.so /usr/local/lib/
sudo ldconfig

# 7. Create simple JNI wrapper for Faiss
cd ~/go_page_size/examples/java/faiss/
mkdir -p native
cat > native/faiss_jni.cpp << 'EOF'
#include <jni.h>
#include <faiss/IndexFlat.h>
#include <iostream>
#include <cstdio>

extern "C" {
    JNIEXPORT jlong JNICALL Java_com_example_FaissDemo_createIndex(JNIEnv *env, jclass cls, jint dimension) {
        printf("hello from custom faiss\n"); fflush(stdout);
        faiss::IndexFlatL2* index = new faiss::IndexFlatL2(dimension);
        return reinterpret_cast<jlong>(index);
    }
    
    JNIEXPORT void JNICALL Java_com_example_FaissDemo_deleteIndex(JNIEnv *env, jclass cls, jlong indexPtr) {
        faiss::IndexFlatL2* index = reinterpret_cast<faiss::IndexFlatL2*>(indexPtr);
        delete index;
    }
}
EOF

# 8. Compile JNI wrapper
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
g++ -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I/usr/local/include -L/usr/local/lib \
    native/faiss_jni.cpp -lfaiss -o native/libfaiss_jni.so

# 9. Copy to system library path
sudo cp native/libfaiss_jni.so /usr/local/lib/
sudo ldconfig

# 10. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/FaissDemo.java << 'EOF'
package com.example;

public class FaissDemo {
    // Native method declarations
    public static native long createIndex(int dimension);
    public static native void deleteIndex(long indexPtr);
    
    static {
        // Load our custom Faiss JNI library
        System.load("/usr/local/lib/libfaiss_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("Faiss Demo Starting...");
            
            // Create a Faiss index (this will trigger our custom printf)
            System.out.println("Creating Faiss index...");
            long indexPtr = createIndex(128);
            
            System.out.println("Faiss index created successfully!");
            System.out.println("Index pointer: " + indexPtr);
            
            // Clean up
            deleteIndex(indexPtr);
            System.out.println("Faiss demo completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# 11. Compile and run the demo
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/FaissDemo.java
echo "Running Faiss demo with custom library..."
java -cp target/classes com.example.FaissDemo