package com.example.helloworld;

import java.io.File;

public class HelloWorldJNI {
    // Native method declarations
    public native int getPageSize();
    public native int getCPUCores();
    public native String getCPUModel();
    
    public static void main(String[] args) {
        try {
            // Get the absolute path to the native library
            String libPath = new File("/home/ubuntu/go_page_size/java/0718/jnind4jcpu/hello_world/build/lib/libhelloworldjni.so").getAbsolutePath();
            
            // Explicitly load the native library
            System.out.println("Loading native library: " + libPath);
            System.load(libPath);
            
            System.out.println("Native library loaded successfully!");
            
            // Create an instance of this class
            HelloWorldJNI app = new HelloWorldJNI();
            
            // Call the native methods
            int pageSize = app.getPageSize();
            System.out.println("Hello World! JNI call successful.");
            System.out.println("System page size: " + pageSize + " bytes");
            
            // Call other methods to demonstrate they work too
            System.out.println("CPU cores: " + app.getCPUCores());
            System.out.println("CPU model: " + app.getCPUModel());
            
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
