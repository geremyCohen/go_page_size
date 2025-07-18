#include <jni.h>
#include <cstdint>
#include <cstring>
#include <cstdlib>
#include <ctime>
#include "com_ucrypto_UCrypto.h"

/*
 * Class:     com_ucrypto_UCrypto
 * Method:    encrypt
 * Signature: ([B[B)[B
 */
JNIEXPORT jbyteArray JNICALL Java_com_ucrypto_UCrypto_encrypt
  (JNIEnv *env, jobject obj, jbyteArray data, jbyteArray key) {
    
    // Get the data and key as C arrays
    jbyte *dataBytes = env->GetByteArrayElements(data, NULL);
    jbyte *keyBytes = env->GetByteArrayElements(key, NULL);
    
    jsize dataLength = env->GetArrayLength(data);
    jsize keyLength = env->GetArrayLength(key);
    
    // Create a new byte array for the result
    jbyteArray result = env->NewByteArray(dataLength);
    jbyte *resultBytes = env->GetByteArrayElements(result, NULL);
    
    // Simple XOR encryption
    for (int i = 0; i < dataLength; i++) {
        resultBytes[i] = dataBytes[i] ^ keyBytes[i % keyLength];
    }
    
    // Release the arrays
    env->ReleaseByteArrayElements(result, resultBytes, 0);
    env->ReleaseByteArrayElements(data, dataBytes, JNI_ABORT);
    env->ReleaseByteArrayElements(key, keyBytes, JNI_ABORT);
    
    return result;
}

/*
 * Class:     com_ucrypto_UCrypto
 * Method:    decrypt
 * Signature: ([B[B)[B
 */
JNIEXPORT jbyteArray JNICALL Java_com_ucrypto_UCrypto_decrypt
  (JNIEnv *env, jobject obj, jbyteArray data, jbyteArray key) {
    
    // Decryption is the same as encryption for XOR
    return Java_com_ucrypto_UCrypto_encrypt(env, obj, data, key);
}

/*
 * Class:     com_ucrypto_UCrypto
 * Method:    generateKey
 * Signature: (I)[B
 */
JNIEXPORT jbyteArray JNICALL Java_com_ucrypto_UCrypto_generateKey
  (JNIEnv *env, jobject obj, jint length) {
    
    // Create a new byte array for the key
    jbyteArray key = env->NewByteArray(length);
    jbyte *keyBytes = env->GetByteArrayElements(key, NULL);
    
    // Seed the random number generator
    static bool seeded = false;
    if (!seeded) {
        srand(time(NULL));
        seeded = true;
    }
    
    // Generate random bytes
    for (int i = 0; i < length; i++) {
        keyBytes[i] = (jbyte)(rand() % 256);
    }
    
    // Release the array
    env->ReleaseByteArrayElements(key, keyBytes, 0);
    
    return key;
}
