# TcNative Java Demo

This project demonstrates loading a custom-compiled TcNative library in Java via JNI.

## What it does

1. Creates a simple custom JNI library that prints "hello from custom tcnative"
2. Compiles the custom JNI library with gcc
3. Creates a Java application that calls TcNative functions to verify the custom library is working

## Usage

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:
- Install all dependencies
- Create and compile a custom JNI wrapper
- Set up the Java project
- Run the demo application

## Expected Output

When running successfully, you should see:
```
TcNative Demo Starting...
hello from custom tcnative
TcNative version: Custom TcNative 1.0.0
hello from custom tcnative
Initializing TcNative...
hello from custom tcnative
TcNative initialized successfully!
TcNative demo completed successfully!
```

The "hello from custom tcnative" messages confirm your custom JNI library is being used.

## Notes

- Uses a simple custom JNI library instead of full TcNative compilation
- Demonstrates custom library loading concept without complex TcNative build issues
- Shows "hello from custom tcnative" message when TcNative operations are performed
- Uses caching to speed up subsequent runs by avoiding slow directory searches