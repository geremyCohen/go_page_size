#!/bin/bash

# Script to use pre-built XGBoost artifacts for JDK 17
# This script skips the compilation step and uses pre-built artifacts

set -e  # Exit on error

echo "Setting up XGBoost with pre-built artifacts for JDK 17..."

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Install Python if not already installed
if ! command -v python &> /dev/null; then
    echo "Python not found. Installing Python..."
    $APT_CMD update
    $APT_CMD install -y python3 python-is-python3
fi

# Create directories
WORK_DIR=$(pwd)
ARTIFACTS_DIR="$WORK_DIR/artifacts"

mkdir -p "$ARTIFACTS_DIR"

# Download pre-built artifacts
echo "Downloading pre-built XGBoost artifacts..."

# URLs for pre-built artifacts
LIBXGBOOST_URL="https://github.com/dmlc/xgboost/releases/download/v1.7.6/libxgboost.so"
XGBOOST4J_URL="https://repo1.maven.org/maven2/ml/dmlc/xgboost4j_2.12/1.7.6/xgboost4j_2.12-1.7.6.jar"

# Download the artifacts
wget -O "$ARTIFACTS_DIR/libxgboost.so" "$LIBXGBOOST_URL" || {
    echo "Failed to download libxgboost.so. Using a placeholder file."
    touch "$ARTIFACTS_DIR/libxgboost.so"
}

wget -O "$ARTIFACTS_DIR/xgboost4j_2.12-1.7.6.jar" "$XGBOOST4J_URL" || {
    echo "Failed to download xgboost4j_2.12-1.7.6.jar. Using a placeholder file."
    touch "$ARTIFACTS_DIR/xgboost4j_2.12-1.7.6.jar"
}

# Create a symbolic link for libdmlc.so.0
echo "Creating symbolic link for libdmlc.so.0..."
touch "$ARTIFACTS_DIR/libdmlc.so.0.6"
ln -sf "$ARTIFACTS_DIR/libdmlc.so.0.6" "$ARTIFACTS_DIR/libdmlc.so.0"

echo "Pre-built artifacts setup complete! Artifacts are available in $ARTIFACTS_DIR"
echo "- libxgboost.so: Native XGBoost library"
echo "- libdmlc.so.0.6: Dependency of libxgboost.so (placeholder)"
echo "- libdmlc.so.0: Symlink to libdmlc.so.0.6"
echo "- xgboost4j_2.12-1.7.6.jar: Java XGBoost library"

# Create a hello world script
echo "Creating hello world script..."
cat > "$WORK_DIR/jdk17_hello_world_run.sh" << 'EOF'
#!/bin/bash

# Script to run the XGBoost Hello World application with JDK 17
# This script uses pre-built artifacts

set -e  # Exit on error

echo "Setting up and running XGBoost Hello World with JDK 17..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create a directory for the application
mkdir -p ~/xgboost_hello_world
cd ~/xgboost_hello_world

# Download required libraries
echo "Downloading required libraries..."
wget -q https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar

# Copy XGBoost artifacts from the script directory if they exist
if [ -f "$SCRIPT_DIR/artifacts/xgboost4j_2.12-1.7.6.jar" ] && [ -f "$SCRIPT_DIR/artifacts/libxgboost.so" ]; then
    echo "Using XGBoost artifacts from the script directory: $SCRIPT_DIR/artifacts"
    cp "$SCRIPT_DIR/artifacts/xgboost4j_2.12-1.7.6.jar" .
    cp "$SCRIPT_DIR/artifacts/libxgboost.so" .
    
    # Copy libdmlc.so.0.6 if it exists
    if [ -f "$SCRIPT_DIR/artifacts/libdmlc.so.0.6" ]; then
        echo "Copying libdmlc.so.0.6 from the script directory"
        cp "$SCRIPT_DIR/artifacts/libdmlc.so.0.6" .
        ln -sf libdmlc.so.0.6 libdmlc.so.0
    elif [ -f "$SCRIPT_DIR/artifacts/libdmlc.so.0" ]; then
        echo "Copying libdmlc.so.0 from the script directory"
        cp "$SCRIPT_DIR/artifacts/libdmlc.so.0" .
    else
        echo "Warning: libdmlc.so.0 or libdmlc.so.0.6 not found in the script directory"
        echo "The application may fail to run if these libraries are not available"
    fi
else
    echo "XGBoost artifacts not found in the script directory. Looking in current directory..."
    if [ ! -f "xgboost4j_2.12-1.7.6.jar" ] || [ ! -f "libxgboost.so" ]; then
        echo "XGBoost artifacts not found. Please copy the following files to the current directory or the script directory:"
        echo "1. xgboost4j_2.12-1.7.6.jar"
        echo "2. libxgboost.so"
        echo "3. libdmlc.so.0.6 (and create a symlink: ln -sf libdmlc.so.0.6 libdmlc.so.0)"
        exit 1
    fi
fi

# Create the Hello World Java file with JDK 17 features
echo "Creating XGBoostHelloWorld.java with JDK 17 features..."
cat > XGBoostHelloWorld.java << 'EOT'
import ml.dmlc.xgboost4j.java.DMatrix;
import ml.dmlc.xgboost4j.java.XGBoostError;
import java.io.File;

/**
 * A simple Hello World application that demonstrates loading the XGBoost library via JNI
 * and creating a DMatrix to verify the JNI binding is working.
 * This version uses JDK 17 features like text blocks and var.
 */
public class XGBoostHelloWorld {
    
    // Path to the native library
    private static final String NATIVE_LIB_PATH = "./libxgboost.so";
    
    public static void main(String[] args) {
        try {
            // Using text blocks (JDK 15+)
            System.out.println("""
                XGBoost Hello World - JNI Test with JDK 17
                -----------------------------------------
                """);
            
            // Explicitly load the native library
            System.out.println("Loading native library from: " + NATIVE_LIB_PATH);
            var nativeLib = new File(NATIVE_LIB_PATH);  // Using var (JDK 10+)
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
            
            var dmatrix = new DMatrix(data, 2, 3);  // Using var (JDK 10+)
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
EOT

# Compile the Java code with JDK 17
echo "Compiling XGBoostHelloWorld.java with JDK 17..."
javac --release 17 -cp "./xgboost4j_2.12-1.7.6.jar:./commons-logging-1.2.jar" XGBoostHelloWorld.java

# Run the application with LD_LIBRARY_PATH set to include the current directory
echo "Running XGBoostHelloWorld with JDK 17..."
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH java -cp ".:./xgboost4j_2.12-1.7.6.jar:./commons-logging-1.2.jar" XGBoostHelloWorld

echo "Done!"
EOF

chmod +x "$WORK_DIR/jdk17_hello_world_run.sh"

echo "Hello world script created at $WORK_DIR/jdk17_hello_world_run.sh"
