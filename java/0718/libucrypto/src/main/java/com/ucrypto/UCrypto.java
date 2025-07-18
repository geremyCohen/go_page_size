package com.ucrypto;

/**
 * UCrypto - A simple JNI-enabled cryptography library
 */
public class UCrypto {
    static {
        System.loadLibrary("ucrypto");
    }

    /**
     * Encrypts the given data using a simple XOR algorithm
     * 
     * @param data The data to encrypt
     * @param key The encryption key
     * @return The encrypted data
     */
    public native byte[] encrypt(byte[] data, byte[] key);

    /**
     * Decrypts the given data using a simple XOR algorithm
     * 
     * @param data The data to decrypt
     * @param key The decryption key
     * @return The decrypted data
     */
    public native byte[] decrypt(byte[] data, byte[] key);

    /**
     * Generates a random key of the specified length
     * 
     * @param length The length of the key to generate
     * @return A random key
     */
    public native byte[] generateKey(int length);
}
