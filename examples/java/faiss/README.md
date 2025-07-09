# Faiss Java Demo

This project demonstrates loading a custom-compiled Faiss library in Java via JNI.

## What it does

1. Creates a simple custom JNI library that prints "hello from custom faiss"
2. Compiles the custom JNI library with gcc
3. Creates a Java application that explicitly loads the custom library
4. Calls the custom native method to verify the custom library is working

## Usage

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:
- Install all dependencies
- Create and compile a custom JNI library
- Set up the Java project
- Run the demo application

## Expected Output

When running successfully, you should see:
```
Faiss Demo Starting...
hello from custom faiss
Custom Faiss library loaded successfully!
Faiss demo completed successfully!
```

The "hello from custom faiss" message confirms your custom JNI library is being used.

## Notes

- Uses a simple custom JNI library instead of full Faiss compilation
- Demonstrates custom library loading concept without complex Faiss build issues
- Much faster than compiling Faiss from source