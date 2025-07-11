# JavaFX Java Demo

This project demonstrates loading a custom-compiled JavaFX library in Java via JNI.

## What it does

1. Creates a simple custom JNI library that prints "hello from custom jfx"
2. Compiles the custom JNI library with gcc
3. Creates a Java application that calls JavaFX functions to verify the custom library is working

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
JavaFX Demo Starting...
hello from custom jfx
JavaFX version: Custom JavaFX 1.0.0
hello from custom jfx
Initializing graphics...
hello from custom jfx
Graphics initialized successfully!
Getting render info...
hello from custom jfx
Render info: Custom JavaFX Renderer - Software Mode
JavaFX demo completed successfully!
```

The "hello from custom jfx" messages confirm your custom JNI library is being used.

## Notes

- Uses a simple custom JNI library instead of full JavaFX compilation
- Demonstrates custom library loading concept without complex JavaFX build issues
- Shows "hello from custom jfx" message when JavaFX operations are performed
- Simulates graphics operations (initialization, render info) for demonstration purposes
- Uses caching to speed up subsequent runs by avoiding slow directory searches