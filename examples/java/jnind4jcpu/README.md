# ND4J CPU Java Demo

This project demonstrates loading a custom-compiled ND4J CPU library in Java via JNI.

## What it does

1. Clones ND4J from source (DeepLearning4J repository)
2. Compiles ND4J CPU backend from source using out-of-tree build
3. Creates a JNI wrapper that uses the custom ND4J library and prints "hello from custom nd4j"
4. Creates a Java application that performs array operations to verify the custom library is working

## Usage

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:
- Install all dependencies
- Clone and compile ND4J from source in a separate build directory
- Create and compile a custom JNI wrapper
- Set up the Java project
- Run the demo application

## Expected Output

When running successfully, you should see:
```
ND4J Demo Starting...
hello from custom nd4j
Creating array...
hello from custom nd4j
ND4J array created successfully!
Array values: 0.0 1.5 3.0 4.5 6.0 
ND4J demo completed successfully!
```

The "hello from custom nd4j" messages confirm your custom JNI library is being used with the custom-compiled ND4J.

## Notes

- Compiles ND4J CPU backend from source using out-of-tree build to keep source directory clean
- Demonstrates loading custom-compiled ND4J library through JNI wrapper
- Shows "hello from custom nd4j" message when array operations are performed
- Uses caching to speed up subsequent runs by avoiding slow directory searches