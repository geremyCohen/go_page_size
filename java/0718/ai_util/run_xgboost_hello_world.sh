#!/bin/bash

# Script to compile and run the XGBoost Hello World application on another machine
# This script assumes that default_jre_jni_install.sh has been run to set up the JDK

set -e  # Exit on error

echo "Setting up and running XGBoost Hello World..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create a directory for the application
mkdir -p ~/xgboost_hello_world
cd ~/xgboost_hello_world

# Download required libraries
echo "Downloading required libraries..."
wget -q https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar

# Copy XGBoost artifacts from the script directory if they exist
if [ -f "$SCRIPT_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ] && [ -f "$SCRIPT_DIR/libxgboost.so" ]; then
    echo "Using XGBoost artifacts from the script directory: $SCRIPT_DIR"
    cp "$SCRIPT_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" .
    cp "$SCRIPT_DIR/libxgboost.so" .
    
    # Copy libdmlc.so.0.6 if it exists
    if [ -f "$SCRIPT_DIR/libdmlc.so.0.6" ]; then
        echo "Copying libdmlc.so.0.6 from the script directory"
        cp "$SCRIPT_DIR/libdmlc.so.0.6" .
        ln -sf libdmlc.so.0.6 libdmlc.so.0
    elif [ -f "$SCRIPT_DIR/libdmlc.so.0" ]; then
        echo "Copying libdmlc.so.0 from the script directory"
        cp "$SCRIPT_DIR/libdmlc.so.0" .
    else
        echo "Warning: libdmlc.so.0 or libdmlc.so.0.6 not found in the script directory"
        echo "The application may fail to run if these libraries are not available"
    fi
else
    echo "XGBoost artifacts not found in the script directory. Looking in current directory..."
    if [ ! -f "xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ] || [ ! -f "libxgboost.so" ]; then
        echo "XGBoost artifacts not found. Please copy the following files to the current directory or the script directory:"
        echo "1. xgboost4j_2.12-3.1.0-SNAPSHOT.jar"
        echo "2. libxgboost.so"
        echo "3. libdmlc.so.0.6 (and create a symlink: ln -sf libdmlc.so.0.6 libdmlc.so.0)"
        exit 1
    fi
fi

# Create the Hello World Java file
echo "Creating XGBoostHelloWorld.java..."
cat > XGBoostHelloWorld.java << 'EOF'
import ml.dmlc.xgboost4j.java.DMatrix;
import ml.dmlc.xgboost4j.java.XGBoostError;
import java.io.File;

/**
 * A simple Hello World application that demonstrates loading the XGBoost library via JNI
 * and creating a DMatrix to verify the JNI binding is working.
 */
public class XGBoostHelloWorld {
    
    // Path to the native library
    private static final String NATIVE_LIB_PATH = "./libxgboost.so";
    
    public static void main(String[] args) {
        try {
            System.out.println("XGBoost Hello World - JNI Test");
            System.out.println("------------------------------");
            
            // Explicitly load the native library
            System.out.println("Loading native library from: " + NATIVE_LIB_PATH);
            File nativeLib = new File(NATIVE_LIB_PATH);
            if (!nativeLib.exists()) {
                throw new RuntimeException("Native library not found at: " + NATIVE_LIB_PATH);
            }
            System.load(nativeLib.getAbsolutePath());
            System.out.println("Native library loaded successfully!");
            
            // Create a simple DMatrix
            System.out.println("\nCreating a simple DMatrix...");
            float[] data = new float[] {
                1.0f, 2.0f, 3.0f,
                4.0f, 5.0f, 6.0f
            };
            float[] labels = new float[] {0.0f, 1.0f};
            
            DMatrix dmatrix = new DMatrix(data, 2, 3);
            dmatrix.setLabel(labels);
            
            System.out.println("DMatrix created successfully!");
            System.out.println("Number of rows: " + dmatrix.rowNum());
            
            // Clean up
            dmatrix.dispose();
            System.out.println("DMatrix disposed successfully!");
            
            System.out.println("\nJNI test completed successfully!");
            
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (XGBoostError e) {
            System.err.println("XGBoost error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error during XGBoost JNI test: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# Compile the Java code
echo "Compiling XGBoostHelloWorld.java..."
javac -cp "./xgboost4j_2.12-3.1.0-SNAPSHOT.jar:./commons-logging-1.2.jar" XGBoostHelloWorld.java

# Run the application with LD_LIBRARY_PATH set to include the current directory
echo "Running XGBoostHelloWorld..."
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH java -cp ".:./xgboost4j_2.12-3.1.0-SNAPSHOT.jar:./commons-logging-1.2.jar" XGBoostHelloWorld

echo "Done!"
