#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    python3-pip python3-dev wget tcl-dev

# 2. Clean up any existing files
sudo rm -rf ~/sqlite
sudo rm -rf ~/sqlite-build
# Find the project directory dynamically with caching
CACHE_FILE="$HOME/.sql_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "sql" -path "*/examples/java/sql" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -n "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR/target"
    rm -rf "$PROJECT_DIR/native"
fi

# 3. Clone SQLite from source
cd
if [ ! -d "~/sqlite" ]; then
    git clone https://github.com/sqlite/sqlite.git ~/sqlite
fi
cd ~/sqlite

# 4. Skip patching SQLite source - we'll add the message to JNI wrapper instead
echo "Skipping SQLite source patching - using JNI wrapper approach"

# 5. Build SQLite from source using out-of-tree build
cd ~/sqlite
# Create a separate build directory
mkdir -p ../sqlite-build && cd ../sqlite-build
# Configure from the separate build directory
~/sqlite/configure --enable-shared --prefix=/usr/local
make -j$(nproc)
sudo make install
sudo ldconfig

# 6. Copy SQLite library to system library path (if needed)
echo "SQLite library installed to /usr/local/lib"

# 7. Create simple JNI wrapper for SQLite
# Use cached project directory
CACHE_FILE="$HOME/.sql_project_path_cache"
if [ -f "$CACHE_FILE" ] && [ -d "$(cat "$CACHE_FILE")" ]; then
    PROJECT_DIR=$(cat "$CACHE_FILE")
else
    PROJECT_DIR=$(find ~ -name "sql" -path "*/java/sql" 2>/dev/null | head -1)
    if [ -n "$PROJECT_DIR" ]; then
        echo "$PROJECT_DIR" > "$CACHE_FILE"
    fi
fi
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Could not find sql project directory"
    exit 1
fi
cd "$PROJECT_DIR"
mkdir -p native
cat > native/sqlite_jni.c << 'EOF'
#include <jni.h>
#include <sqlite3.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

JNIEXPORT jlong JNICALL Java_com_example_SQLiteDemo_openDatabase(JNIEnv *env, jclass cls, jstring dbPath) {
    printf("****** hello from custom sqlite\n"); fflush(stdout);
    
    const char *path = (*env)->GetStringUTFChars(env, dbPath, 0);
    sqlite3 *db;
    int rc = sqlite3_open(path, &db);
    (*env)->ReleaseStringUTFChars(env, dbPath, path);
    
    if (rc != SQLITE_OK) {
        return 0;
    }
    return (jlong)(uintptr_t)db;
}

JNIEXPORT void JNICALL Java_com_example_SQLiteDemo_closeDatabase(JNIEnv *env, jclass cls, jlong dbPtr) {
    sqlite3 *db = (sqlite3*)(uintptr_t)dbPtr;
    if (db) {
        sqlite3_close(db);
    }
}

JNIEXPORT jstring JNICALL Java_com_example_SQLiteDemo_getVersion(JNIEnv *env, jclass cls) {
    return (*env)->NewStringUTF(env, sqlite3_libversion());
}
EOF

# 8. Compile JNI wrapper
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME: $JAVA_HOME"
gcc -shared -fPIC -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" \
    -I/usr/local/include -L/usr/local/lib \
    native/sqlite_jni.c -lsqlite3 -o native/libsqlite_jni.so

# 9. Copy to system library path
sudo cp native/libsqlite_jni.so /usr/local/lib/
sudo ldconfig

# 10. Create the Java application
mkdir -p src/main/java/com/example
cat > src/main/java/com/example/SQLiteDemo.java << 'EOF'
package com.example;

public class SQLiteDemo {
    // Native method declarations
    public static native long openDatabase(String dbPath);
    public static native void closeDatabase(long dbPtr);
    public static native String getVersion();
    
    static {
        // Load our custom SQLite JNI library
        System.load("/usr/local/lib/libsqlite_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("SQLite Demo Starting...");
            
            // Get SQLite version and open database (this will trigger our custom printf)
            System.out.println("SQLite version: " + getVersion());
            System.out.println("Opening database...");
            long dbPtr = openDatabase(":memory:");
            
            if (dbPtr != 0) {
                System.out.println("SQLite database opened successfully!");
                System.out.println("Database pointer: " + dbPtr);
                
                // Clean up
                closeDatabase(dbPtr);
                System.out.println("SQLite demo completed successfully!");
            } else {
                System.out.println("Failed to open SQLite database");
            }
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# 11. Compile and run the demo
mkdir -p target/classes
javac -d target/classes src/main/java/com/example/SQLiteDemo.java
echo "Running SQLite demo with custom library..."
java -cp target/classes com.example.SQLiteDemo