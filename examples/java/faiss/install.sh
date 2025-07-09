#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget libblas-dev liblapack-dev swig

# 2. Clean up any existing files
rm -rf ~/faiss
rm -rf ~/go_page_size/examples/java/faiss/target

# 3. Clone Faiss from source
cd
git clone https://github.com/facebookresearch/faiss.git ~/faiss
cd ~/faiss

# 4. Patch Faiss to add custom printf
FAISS_SRC=~/faiss/faiss/IndexFlat.cpp
if [ -f "$FAISS_SRC" ]; then
    echo "Patching $FAISS_SRC"
    # Add include for printf at the top
    sed -i '1i#include <cstdio>' "$FAISS_SRC"
    
    # Clean up any previous patches
    sed -i '/printf.*hello from custom faiss/d' "$FAISS_SRC"
    sed -i '/fflush(stdout);/d' "$FAISS_SRC"
    
    # Find IndexFlat constructor and add our custom print
    sed -i '/IndexFlat::IndexFlat.*int.*MetricType/,/^{$/ {
        /^{$/ a\    printf("hello from custom faiss\\n"); fflush(stdout);
    }' "$FAISS_SRC"
    
    # Verify the patch was applied
    if grep -q "hello from custom faiss" "$FAISS_SRC"; then
        echo "✓ Patch successfully applied"
        echo "Patch verification:"
        grep -A2 -B2 "hello from custom faiss" "$FAISS_SRC"
    else
        echo "✗ Patch may not have been applied correctly"
    fi
else
    echo "IndexFlat.cpp not found"
    find ~/faiss/faiss/ -name "*.cpp" | head -5
fi

# 5. Build Faiss with Java bindings
cd ~/faiss
mkdir -p build && cd build
cmake -DFAISS_ENABLE_PYTHON=OFF \
      -DFAISS_ENABLE_GPU=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
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

extern "C" {
    JNIEXPORT jlong JNICALL Java_com_example_FaissDemo_createIndex(JNIEnv *env, jclass cls, jint dimension) {
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