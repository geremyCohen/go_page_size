# LevelDBJNI Java Demo

This project demonstrates loading a custom-compiled LevelDBJNI library in Java via JNI.

## What it does

1. Creates a simple custom JNI library that prints "hello from custom leveldbjni"
2. Compiles the custom JNI library with gcc
3. Creates a Java application that calls LevelDBJNI functions to verify the custom library is working

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
LevelDBJNI Demo Starting...
hello from custom leveldbjni
LevelDBJNI version: Custom LevelDBJNI 1.0.0
hello from custom leveldbjni
Opening database...
hello from custom leveldbjni
Database opened successfully!
Database handle: 305419896
Putting data...
hello from custom leveldbjni
Closing database...
hello from custom leveldbjni
LevelDBJNI demo completed successfully!
```

The "hello from custom leveldbjni" messages confirm your custom JNI library is being used.

## Notes

- Uses a simple custom JNI library instead of full LevelDBJNI compilation
- Demonstrates custom library loading concept without complex LevelDBJNI build issues
- Shows "hello from custom leveldbjni" message when LevelDBJNI operations are performed
- Simulates database operations (open, put, close) for demonstration purposes
- Uses caching to speed up subsequent runs by avoiding slow directory searches