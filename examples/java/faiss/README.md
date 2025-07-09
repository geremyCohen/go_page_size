# Faiss Java Demo

This project demonstrates loading a custom-compiled Faiss library in Java via JNI.

## What it does

1. Clones Faiss from source
2. Patches the Faiss IndexFlat constructor to print "hello from custom faiss"
3. Compiles Faiss from source with the patch
4. Creates a JNI wrapper that uses the custom Faiss library
5. Creates a Java application that creates a Faiss index to verify the custom library is working

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
Creating Faiss index...
hello from custom faiss
Faiss index created successfully!
Index pointer: 140123456789
Faiss demo completed successfully!
```

The "hello from custom faiss" message confirms your custom JNI library is being used.

## Notes

- Compiles Faiss from source with a custom patch
- Demonstrates loading custom-compiled Faiss library instead of system version
- Shows "hello from custom faiss" message when IndexFlat constructor is called