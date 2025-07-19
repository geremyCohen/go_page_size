#!/bin/bash

# Script to clone the repository and run the JDK17-only compile and hello world scripts
# This script assumes it's being run on a fresh Ubuntu installation

set -e  # Exit on error

echo "=== XGBoost JDK17 Clone and Run Script ==="
echo "This script will:"
echo "1. Install git and other required tools"
echo "2. Clone the repository"
echo "3. Run the JDK17 installation script"
echo "4. Run the JDK17 XGBoost compile script"
echo "5. Run the JDK17 XGBoost hello world script"
echo ""

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Install git and other required tools
echo "=== Installing git and other required tools ==="
$APT_CMD update
$APT_CMD install -y git wget maven

# Create a directory for the repository
REPO_DIR="$HOME/xgboost_jdk17_test"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# Clone the repository (using a placeholder URL - replace with your actual repository URL)
echo "=== Cloning the repository ==="
# Note: Replace the URL below with your actual repository URL
git clone https://github.com/your-username/your-repo.git .

# Navigate to the JDK17 scripts directory
cd go_page_size/java/0718/libxgboost4j/4

# Make the scripts executable
chmod +x jdk17_install.sh compile_xgboost_jdk17.sh jdk17_hello_world_run.sh

# Run the JDK17 installation script
echo "=== Running JDK17 installation script ==="
./jdk17_install.sh

# Source the updated environment variables
source ~/.bashrc

# Run the JDK17 XGBoost compile script
echo "=== Running JDK17 XGBoost compile script ==="
./compile_xgboost_jdk17.sh

# Run the JDK17 XGBoost hello world script
echo "=== Running JDK17 XGBoost hello world script ==="
./jdk17_hello_world_run.sh

echo ""
echo "=== All done! ==="
echo "The JDK17 XGBoost installation, compilation, and hello world test have been completed successfully."
