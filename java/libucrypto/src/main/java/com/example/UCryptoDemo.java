package com.example;

public class UCryptoDemo {
    // Native method declarations
    public static native void printCustomMessage();
    public static native String getVersion();
    public static native byte[] encrypt(byte[] data);
    
    static {
        // Load our custom UCrypto JNI library
        System.load("/usr/local/lib/libucrypto_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("UCrypto Demo Starting...");
            
            // Call custom message method
            printCustomMessage();
            
            // Get version (this will also trigger our custom printf)
            System.out.println("UCrypto version: " + getVersion());
            
            // Encrypt some data (this will also trigger our custom printf)
            System.out.println("Encrypting data...");
            String testData = "Hello World!";
            byte[] encrypted = encrypt(testData.getBytes());
            
            if (encrypted != null) {
                System.out.println("Original: " + testData);
                System.out.print("Encrypted bytes: ");
                for (byte b : encrypted) {
                    System.out.printf("%02x ", b);
                }
                System.out.println();
                System.out.println("UCrypto encryption completed successfully!");
                System.out.println("UCrypto demo completed successfully!");
            } else {
                System.out.println("Failed to encrypt data");
            }
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
