# XGBoost Hello World JNI Test

This directory contains a script to test the XGBoost JNI integration on a target machine.

## Prerequisites

1. The target machine should have JDK installed (the script assumes that `default_jre_jni_install.sh` has been run)
2. The following XGBoost artifacts must be available:
   - `xgboost4j_2.12-3.1.0-SNAPSHOT.jar`
   - `libxgboost.so`
   - `libdmlc.so.0.6` (or `libdmlc.so.0`)

## Script Overview

The `run_xgboost_hello_world.sh` script performs the following actions:

1. Creates a directory for the application (`~/xgboost_hello_world`)
2. Downloads the required Commons Logging library
3. Copies the XGBoost artifacts from the script directory (if available)
4. Creates a simple Java application that tests the XGBoost JNI integration
5. Compiles and runs the application

## Usage

1. Copy the script and XGBoost artifacts to the target machine
2. Make the script executable: `chmod +x run_xgboost_hello_world.sh`
3. Run the script: `./run_xgboost_hello_world.sh`

## Expected Output

If the script runs successfully, you should see output similar to:

```
XGBoost Hello World - JNI Test
------------------------------
Loading native library from: ./libxgboost.so
Native library loaded successfully!

Creating a simple DMatrix...
DMatrix created successfully!
Number of rows: 2
DMatrix disposed successfully!

JNI test completed successfully!
```

## Troubleshooting

If the script fails with an `UnsatisfiedLinkError`, check that:
1. The native libraries (`libxgboost.so` and `libdmlc.so.0`) are in the correct location
2. The `LD_LIBRARY_PATH` environment variable includes the directory with these libraries
3. The libraries are compatible with the target machine's architecture (ARM64)

## Notes

This script is designed to work with the XGBoost artifacts built for ARM64 architecture on Ubuntu. The artifacts should be built using the installation script provided in the project.

The key dependency is `libdmlc.so.0`, which is required by `libxgboost.so`. The script will create a symbolic link from `libdmlc.so.0.6` to `libdmlc.so.0` if needed.
