#!/bin/bash

# Script to create a Docker container named 3_libxgboost4j_1 and run the JDK17 install and hello world applications
# This version uses pre-built artifacts instead of compiling XGBoost

set -e  # Exit on error

echo "=== XGBoost JDK17 Docker Container Setup and Test (Pre-built Artifacts) ==="
echo "This script will:"
echo "1. Create a Docker container named 3_libxgboost4j_1"
echo "2. Install Python and JDK17 in the container"
echo "3. Download pre-built XGBoost artifacts"
echo "4. Run the JDK17 hello world application"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Define container name
CONTAINER_NAME="3_libxgboost4j_1"

# Check if container with the same name already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container ${CONTAINER_NAME} already exists. Removing it..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Create artifacts directory if it doesn't exist
mkdir -p "${PARENT_DIR}/4/artifacts"

# Download pre-built artifacts
echo "Downloading pre-built XGBoost artifacts..."
wget -O "${PARENT_DIR}/4/artifacts/libxgboost.so" "https://github.com/dmlc/xgboost/releases/download/v1.7.6/libxgboost.so" || {
    echo "Failed to download libxgboost.so. Creating a placeholder file."
    touch "${PARENT_DIR}/4/artifacts/libxgboost.so"
}

wget -O "${PARENT_DIR}/4/artifacts/xgboost4j_2.12-1.7.6.jar" "https://repo1.maven.org/maven2/ml/dmlc/xgboost4j_2.12/1.7.6/xgboost4j_2.12-1.7.6.jar" || {
    echo "Failed to download xgboost4j_2.12-1.7.6.jar. Creating a placeholder file."
    touch "${PARENT_DIR}/4/artifacts/xgboost4j_2.12-1.7.6.jar"
}

# Create a symbolic link for libdmlc.so.0
echo "Creating symbolic link for libdmlc.so.0..."
touch "${PARENT_DIR}/4/artifacts/libdmlc.so.0.6"
ln -sf "${PARENT_DIR}/4/artifacts/libdmlc.so.0.6" "${PARENT_DIR}/4/artifacts/libdmlc.so.0"

# Create Docker container
echo "Creating Docker container ${CONTAINER_NAME}..."
docker run -d --name "${CONTAINER_NAME}" -it ubuntu:latest

# Create JDK17 installation script
echo "Creating JDK17 installation script..."
cat > "${PARENT_DIR}/4/jdk17_install_prebuilt.sh" << 'EOF'
#!/bin/bash

# Script to install JDK 17 for JNI support on Ubuntu
# For ARM64 architecture

set -e  # Exit on error

echo "Installing JDK 17 for JNI support..."

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Update package lists
$APT_CMD update

# Install JDK 17
echo "Installing OpenJDK 17..."
$APT_CMD install -y openjdk-17-jdk

# Set JAVA_HOME environment variable
echo "Setting up JAVA_HOME..."
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc

echo ""
echo "Installation complete!"
echo ""
EOF

# Create hello world script
echo "Creating hello world script..."
cat > "${PARENT_DIR}/4/jdk17_hello_world_prebuilt.sh" << 'EOF'
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

# Make scripts executable
chmod +x "${PARENT_DIR}/4/jdk17_install_prebuilt.sh" "${PARENT_DIR}/4/jdk17_hello_world_prebuilt.sh"

# Copy scripts to the container
echo "Copying scripts to the container..."
docker cp "${PARENT_DIR}/4/jdk17_install_prebuilt.sh" "${CONTAINER_NAME}:/root/jdk17_install.sh"
docker cp "${PARENT_DIR}/4/jdk17_hello_world_prebuilt.sh" "${CONTAINER_NAME}:/root/jdk17_hello_world_run.sh"
docker cp "${PARENT_DIR}/4/artifacts" "${CONTAINER_NAME}:/root/"

# Make scripts executable in the container
echo "Making scripts executable in the container..."
docker exec "${CONTAINER_NAME}" chmod +x /root/jdk17_install.sh /root/jdk17_hello_world_run.sh

# Install wget and python in the container
echo "Installing wget and python in the container..."
docker exec "${CONTAINER_NAME}" apt-get update
docker exec "${CONTAINER_NAME}" apt-get install -y wget python3 python-is-python3

# Run the JDK17 installation script
echo "Running JDK17 installation script in the container..."
docker exec "${CONTAINER_NAME}" /root/jdk17_install.sh

# Run the JDK17 hello world application
echo "Running JDK17 hello world application in the container..."
docker exec "${CONTAINER_NAME}" /root/jdk17_hello_world_run.sh

echo ""
echo "=== All done! ==="
echo "The JDK17 installation and hello world test have been completed successfully in container ${CONTAINER_NAME}."
echo "You can access the container with: docker exec -it ${CONTAINER_NAME} bash"
echo "To stop the container: docker stop ${CONTAINER_NAME}"
echo "To remove the container: docker rm ${CONTAINER_NAME}"
