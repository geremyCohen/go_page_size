# OpenCV Imgproc Java Demo

This project demonstrates loading a custom-compiled OpenCV imgproc library in Java via JNI.

## What it does

1. Clones OpenCV from source
2. Patches the imgproc module to print "hello from custom imgproc" 
3. Compiles OpenCV with Java bindings
4. Creates a Java application that explicitly loads the custom library
5. Performs a simple color conversion operation to verify the custom library is working

## Usage

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:
- Install all dependencies
- Clone and patch OpenCV source
- Compile OpenCV with Java bindings  
- Set up the Maven project
- Run the demo application

## Expected Output

When running successfully, you should see:
```
hello from custom imgproc
OpenCV version: 4.x.x
Performing color conversion...
Color conversion completed successfully!
Original image size: 3x3
Gray image size: 3x3
OpenCV imgproc demo completed successfully!
```

The "hello from custom imgproc" message confirms your custom-compiled library is being used.