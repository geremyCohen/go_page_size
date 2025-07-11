#!/usr/bin/env bash

# Toggle cleanup of previous builds (set to false to skip cleanup)
clean=true

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven openjfx build-essential git wget

# 2. Clean up existing files if requested
if [ "$clean" = true ]; then
  echo "Cleaning up previous build artifacts..."
  sudo rm -f /usr/local/lib/libjfx_custom.so
  rm -rf native target src
fi

# 3. Compile custom JNI library
mkdir -p native
cat > native/jfx_custom.c << 'EOF'
#include <jni.h>
#include <stdio.h>

JNIEXPORT jstring JNICALL Java_com_example_JfxDemo_jfxHelloWorld(JNIEnv *env, jclass cls) {
    printf("Hello from custom JFX native library!\n");
    fflush(stdout);
    return (*env)->NewStringUTF(env, "Hello from JavaFX JNI!");
}
EOF

# Determine JAVA_HOME
JAVA_HOME=$(readlink -f /usr/bin/java | sed 's:/bin/java::')
echo "Using JAVA_HOME: $JAVA_HOME"

# Compile the JNI shared library
gcc -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
  native/jfx_custom.c -o native/libjfx_custom.so

# 4. Install the native library
sudo cp native/libjfx_custom.so /usr/local/lib/
sudo ldconfig

# 5. Create Java application source
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/JfxDemo.java << 'EOF'
package com.example;

import javafx.application.Platform;

public class JfxDemo {
    static {
        String libPath = "/usr/local/lib/libjfx_custom.so";
        try {
            System.load(libPath);
            System.out.println("Loaded custom library from: " + libPath);
        } catch (Throwable t) {
            System.err.println("Failed to load custom JFX library: " + t.getMessage());
            t.printStackTrace();
            System.exit(1);
        }
    }

    public static native String jfxHelloWorld();

    public static void main(String[] args) {
        System.out.println("JFX Demo Starting...");
        try {
            Platform.startup(() -> {});
            System.out.println("JavaFX Platform started successfully.");
        } catch (Throwable t) {
            System.err.println("Failed to initialize JavaFX Platform: " + t.getMessage());
            t.printStackTrace();
            System.exit(1);
        }
        String msg = jfxHelloWorld();
        System.out.println("Native method returned: " + msg);
        System.out.println("JFX Demo completed successfully!");
    }
}
EOF

# 6. Compile and run the demo
FX_LIB_PATH="/usr/share/openjfx/lib"
mkdir -p target/classes
echo "Compiling Java sources with JavaFX modules from: $FX_LIB_PATH"
javac --module-path "$FX_LIB_PATH" --add-modules javafx.graphics \
      -d target/classes src/main/java/com/example/JfxDemo.java
echo "Running JFX Demo with custom library and JavaFX modules..."
java --module-path "$FX_LIB_PATH" --add-modules javafx.graphics \
     -cp target/classes com.example.JfxDemo