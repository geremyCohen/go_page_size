# XGBoost JNI Hello World

This project demonstrates how to compile and use libxgboost4j with JNI support on Arm64 architecture.

## Project Structure

- `ai_build/artifacts/`: Contains the compiled XGBoost artifacts (JARs and native libraries)
- `hello_world/`: Contains the Hello World application that uses the XGBoost JNI bindings
- `default_jre_jni_install.sh`: Script to install JRE/JDK with JNI support on another machine
- `default_jre_jni_hello_world_run.sh`: Script to run the Hello World application on another machine

## Compilation Process

The XGBoost library was compiled with JNI support using the following steps:

1. Clone the XGBoost repository with submodules
2. Ensure the cstdint header is included in the JNI source files for Arm64 compatibility
3. Build XGBoost with CMake using the -DJVM_BINDINGS=ON flag
4. Build the JVM packages with Maven

## Hello World Application

The Hello World application demonstrates how to load the native libraries and call a simple method from the XGBoost library. It performs the following steps:

1. Explicitly load the native libraries using System.load()
2. Call a simple method from the XGBoost library
3. Print the result

## Running on Another Machine

To run the Hello World application on another machine:

1. Copy the `ai_build/artifacts/` directory to the target machine
2. Run the `default_jre_jni_install.sh` script to install the necessary dependencies
3. Run the `default_jre_jni_hello_world_run.sh` script to build and run the Hello World application

## Artifacts

The following artifacts are produced by the compilation process:

- `libxgboost.so`: The main XGBoost native library
- `libxgboost4j.so`: The JNI native library
- `xgboost4j_2.12-3.1.0-SNAPSHOT.jar`: The XGBoost Java API JAR file

See `artifacts.txt` for more details on the locations of these artifacts.
