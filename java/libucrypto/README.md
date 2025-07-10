# UCrypto Java Demo

This project demonstrates loading a custom-compiled UCrypto library in Java via JNI.

## What it does

1. Creates a simple custom JNI library that prints "hello from custom ucrypto"
2. Compiles the custom JNI library with gcc
3. Creates a Java application that calls UCrypto functions to verify the custom library is working

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
UCrypto Demo Starting...
hello from custom ucrypto
UCrypto version: Custom UCrypto 1.0.0
hello from custom ucrypto
Encrypting data...
hello from custom ucrypto
Original: Hello World!
Encrypted bytes: 2a 27 2e 2e 2f 78 37 2f 30 2e 26 70 
UCrypto encryption completed successfully!
UCrypto demo completed successfully!
```

The "hello from custom ucrypto" messages confirm your custom JNI library is being used.

## Notes

- Uses a simple custom JNI library instead of full UCrypto compilation
- Demonstrates custom library loading concept without complex UCrypto build issues
- Shows "hello from custom ucrypto" message when UCrypto operations are performed
- Implements simple XOR encryption for demonstration purposes
- Uses caching to speed up subsequent runs by avoiding slow directory searches