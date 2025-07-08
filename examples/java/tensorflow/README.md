# TensorFlow Java Demo

This project demonstrates loading a custom-compiled TensorFlow library in Java via JNI.

## What it does

1. Clones TensorFlow from source
2. Patches the TensorFlow core to print "hello from custom tensorflow" 
3. Compiles TensorFlow with Java bindings using Bazel
4. Creates a Java application that explicitly loads the custom library
5. Performs a simple tensor creation operation to verify the custom library is working

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
hello from custom tensorflow
TensorFlow version: 2.x.x
Creating tensor...
Tensor created successfully!
Tensor shape: [2, 2]
Tensor value at [0,0]: 1.0
TensorFlow demo completed successfully!
```

The "hello from custom tensorflow" message confirms your custom-compiled library is being used.

## Notes

- TensorFlow compilation can take a very long time (1+ hours)
- Requires significant disk space and memory
- Uses Bazel build system instead of CMake