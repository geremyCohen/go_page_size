# JDK 17 Installation for XGBoost with JNI Support

This directory contains the installation script for setting up JDK 17 and development tools for JNI support on Ubuntu, specifically for ARM64 architecture.

## Files

- `install.sh`: Script to install JDK 17 and development tools for JNI support

## Usage

To install JDK 17 and development tools for JNI support, run:

```bash
./install.sh
```

## What the Script Does

1. Installs OpenJDK 17 instead of OpenJDK 21
2. Installs build tools (build-essential, cmake, git)
3. Installs additional libraries needed for JNI development
4. Sets up the JAVA_HOME environment variable
5. Creates a simple JNI test to verify the setup

## Testing the JNI Setup

After running the installation script, you can test the JNI setup by running:

```bash
cd ~/jni_test && ./build.sh
```

This will compile a simple JNI example and run it to verify that the JNI setup is working correctly.

## Notes

- This script is specifically tailored for ARM64 architecture on Ubuntu
- It includes the necessary libraries and tools for JNI development
- The script has been tested on Ubuntu 24.04
