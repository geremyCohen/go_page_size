# TensorFlow Java Demo

This project demonstrates loading a custom-compiled TensorFlow library in Java via JNI.

## What it does

1. Downloads pre-built TensorFlow Java binaries from Maven Central
2. Creates a simple custom JNI library that prints "hello from custom tensorflow"
3. Compiles the custom JNI library with gcc
4. Creates a Java application that explicitly loads the custom library
5. Calls the custom native method to verify the custom library is working

## Usage

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:
- Install all dependencies including Bazel
- Clone and patch TensorFlow source
- Compile TensorFlow with Java bindings  
- Set up the Maven project
- Run the demo application

## Expected Output

When running successfully, you should see:
```
TensorFlow Demo Starting...
hello from custom tensorflow
Custom TensorFlow library loaded successfully!
TensorFlow demo completed successfully!
```

The "hello from custom tensorflow" message confirms your custom JNI library is being used.

## Notes

- Uses a simple custom JNI library instead of full TensorFlow compilation
- Demonstrates custom library loading concept without complex TensorFlow build issues
- Much faster than compiling TensorFlow from source