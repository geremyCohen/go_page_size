#include <jni.h>
#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include <unistd.h>

// Native method implementation for getSystemInfo
JNIEXPORT jstring JNICALL Java_SimpleJNIDemo_getSystemInfo(JNIEnv *env, jclass cls) {
    struct utsname system_info;
    char result[512];
    
    // Get system information
    if (uname(&system_info) == 0) {
        snprintf(result, sizeof(result), 
            "Native System Info from ARM64 JNI:\n"
            "  System: %s\n"
            "  Node: %s\n" 
            "  Release: %s\n"
            "  Version: %s\n"
            "  Machine: %s\n"
            "  PID: %d",
            system_info.sysname,
            system_info.nodename,
            system_info.release,
            system_info.version,
            system_info.machine,
            getpid()
        );
    } else {
        strcpy(result, "Failed to get system information");
    }
    
    return (*env)->NewStringUTF(env, result);
}

// Native method implementation for addNumbers
JNIEXPORT jint JNICALL Java_SimpleJNIDemo_addNumbers(JNIEnv *env, jclass cls, jint a, jint b) {
    printf("Native C function called: adding %d + %d\n", a, b);
    return a + b;
}

// Native method implementation for getProcessorCount
JNIEXPORT jint JNICALL Java_SimpleJNIDemo_getProcessorCount(JNIEnv *env, jclass cls) {
    long processors = sysconf(_SC_NPROCESSORS_ONLN);
    printf("Native C function: detected %ld processors\n", processors);
    return (jint)processors;
}

// JNI_OnLoad function called when library is loaded
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    printf("Native library loaded successfully on ARM64!\n");
    return JNI_VERSION_1_8;
}
