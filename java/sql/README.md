# SQLite Java Demo

This project demonstrates loading a custom-compiled SQLite library in Java via JNI.

## What it does

1. Clones SQLite from source
2. Compiles SQLite from source using out-of-tree build (keeps source clean)
3. Creates a JNI wrapper that uses the custom SQLite library and prints "hello from custom sqlite"
4. Creates a Java application that opens a SQLite database to verify the custom library is working

## Usage

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:
- Install all dependencies
- Clone and compile SQLite from source in a separate build directory
- Create and compile a custom JNI wrapper
- Set up the Java project
- Run the demo application

## Expected Output

When running successfully, you should see:
```
SQLite Demo Starting...
SQLite version: 3.x.x
Opening database...
hello from custom sqlite
SQLite database opened successfully!
Database pointer: 140123456789
SQLite demo completed successfully!
```

The "hello from custom sqlite" message confirms your custom JNI library is being used with the custom-compiled SQLite.

## Notes

- Compiles SQLite from source using out-of-tree build to keep source directory clean
- Demonstrates loading custom-compiled SQLite library through JNI wrapper
- Shows "hello from custom sqlite" message when database operations are performed