# JNI Hello World Application

This is a simple Hello World application that demonstrates how to use the `libucrypto` JNI library.

## Overview

The application:

1. Sets the `java.library.path` to point to the directory containing the native library
2. Creates an instance of the `UCrypto` class, which loads the native library
3. Calls the `generateKey` method to generate a random key
4. Calls the `encrypt` method to encrypt a message
5. Calls the `decrypt` method to decrypt the message
6. Verifies that the decrypted message matches the original message

## Running the Application

To run the application:

```bash
cd /home/ubuntu/go_page_size/java/0718/libucrypto/hello_world
./run_hello.sh
```

## Setting Up on Another Machine

To set up the JNI Hello World application on another machine:

1. First, run the `default_jre_jni_install.sh` script to install the JDK and JNI development tools:

   ```bash
   ./default_jre_jni_install.sh
   ```

2. Then, run the `default_jre_jni_hello_world_run.sh` script with the project directory as an argument:

   ```bash
   ./default_jre_jni_hello_world_run.sh /path/to/project
   ```

   This will create the Hello World application in the specified directory.

3. Finally, run the Hello World application:

   ```bash
   cd /path/to/project/libucrypto/hello_world
   ./run_hello.sh
   ```

## JNI Methods Used

The Hello World application demonstrates the use of the following JNI methods:

1. `generateKey(int length)` - Generates a random key of the specified length
2. `encrypt(byte[] data, byte[] key)` - Encrypts data using a key
3. `decrypt(byte[] data, byte[] key)` - Decrypts data using a key

These methods are implemented in the native library `libucrypto.so` and exposed through the Java class `com.ucrypto.UCrypto`.
