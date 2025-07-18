# JNI Hello World Application

This is a simple Hello World application that demonstrates how to use JNI to load and call methods from a native library.

## Overview

The application performs the following steps:
1. Explicitly loads the native library using `System.load()`
2. Calls the `getVersion()` method from the native library
3. Calls the `initialize()` method from the native library

## Project Structure

```
hello_world/
├── build.sh                # Script to build the application
├── run.sh                  # Script to run the application
└── src/
    └── main/
        └── java/
            ├── HelloWorldJNI.java                  # Main application class
            └── org/apache/tomcat/jni/Library.java  # JNI interface class
```

## Building and Running

To build and run the application:

1. Make sure you have built the native library first
2. Run the build script: `./build.sh`
3. Run the application: `./run.sh`

## Running on Another Machine

To run the application on another machine:

1. Make sure you have installed the required dependencies using `default_jre_jni_install.sh`
2. Run the `default_jre_jni_hello_world_run.sh` script

## Expected Output

```
Hello World JNI Application
---------------------------
Loading native library from: /path/to/libtcnative-1.so
Native library loaded successfully!

Calling Library.getVersion()...
Library version: 1.0.0

Calling Library.initialize()...
Library initialization result: 0 (0 means success)

JNI calls completed successfully!
```
