#!/bin/bash
# default_jre_jni_hello_world_run.sh
# Script to compile and run the JNI Hello World application on another machine

set -e

# Check if JAVA_HOME is set
if [ -z "$JAVA_HOME" ]; then
    echo "JAVA_HOME is not set. Please run default_jre_jni_install.sh first."
    exit 1
fi

# Define paths
WORK_DIR="$(pwd)"
HELLO_WORLD_DIR="${WORK_DIR}/hello_world"
BUILD_DIR="${HELLO_WORLD_DIR}/build"
NATIVE_LIB_DIR="${WORK_DIR}/ai_build/install/lib"
NATIVE_LIB_PATH="${NATIVE_LIB_DIR}/libtcnative-1.so"

# Check if the native library exists
if [ ! -f "${NATIVE_LIB_PATH}" ]; then
    echo "Native library not found at ${NATIVE_LIB_PATH}"
    echo "Please make sure you have built the native library first."
    exit 1
fi

# Create directories if they don't exist
mkdir -p "${HELLO_WORLD_DIR}/src/main/java/org/apache/tomcat/jni"
mkdir -p "${BUILD_DIR}"

# Create the Library.java file
cat > "${HELLO_WORLD_DIR}/src/main/java/org/apache/tomcat/jni/Library.java" << 'EOF'
package org.apache.tomcat.jni;

public class Library {
    /**
     * Get the version of the native library.
     * 
     * @return The version string of the native library
     */
    public static native String getVersion();
    
    /**
     * Initialize the native library.
     * 
     * @return 0 on success, non-zero on failure
     */
    public static native int initialize();
}
EOF

# Create the HelloWorldJNI.java file
cat > "${HELLO_WORLD_DIR}/src/main/java/HelloWorldJNI.java" << EOF
import org.apache.tomcat.jni.Library;

public class HelloWorldJNI {
    // Path to the native library
    private static final String NATIVE_LIB_PATH = "${NATIVE_LIB_PATH}";

    public static void main(String[] args) {
        try {
            System.out.println("Hello World JNI Application");
            System.out.println("---------------------------");
            
            // Explicitly load the native library
            System.out.println("Loading native library from: " + NATIVE_LIB_PATH);
            System.load(NATIVE_LIB_PATH);
            System.out.println("Native library loaded successfully!");
            
            // Call the getVersion method
            System.out.println("\nCalling Library.getVersion()...");
            String version = Library.getVersion();
            System.out.println("Library version: " + version);
            
            // Call the initialize method
            System.out.println("\nCalling Library.initialize()...");
            int result = Library.initialize();
            System.out.println("Library initialization result: " + result + " (0 means success)");
            
            System.out.println("\nJNI calls completed successfully!");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error during JNI operation: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# Compile the Java code
echo "Compiling Java code..."
javac -d "${BUILD_DIR}" "${HELLO_WORLD_DIR}/src/main/java/org/apache/tomcat/jni/Library.java" "${HELLO_WORLD_DIR}/src/main/java/HelloWorldJNI.java"

# Run the Java application
echo "Running Hello World JNI application..."
java -cp "${BUILD_DIR}" HelloWorldJNI

echo "Application execution completed!"
