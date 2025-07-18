package org.apache.tomcat.jni;

public class Library {
    /**
     * Get the version of the native library.
     * 
     * @return The version string of the native library
     */
    public static native String getVersion();
    
    /**
     * Initialize the native library.
     * 
     * @return 0 on success, non-zero on failure
     */
    public static native int initialize();
}
