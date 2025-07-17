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
