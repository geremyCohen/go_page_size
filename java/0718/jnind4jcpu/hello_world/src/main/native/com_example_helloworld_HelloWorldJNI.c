#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include "com_example_helloworld_HelloWorldJNI.h"

/*
 * Class:     com_example_helloworld_HelloWorldJNI
 * Method:    getPageSize
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_example_helloworld_HelloWorldJNI_getPageSize
  (JNIEnv *env, jobject obj) {
    return (jint)sysconf(_SC_PAGESIZE);
}

/*
 * Class:     com_example_helloworld_HelloWorldJNI
 * Method:    getCPUCores
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_example_helloworld_HelloWorldJNI_getCPUCores
  (JNIEnv *env, jobject obj) {
    return (jint)sysconf(_SC_NPROCESSORS_ONLN);
}

/*
 * Class:     com_example_helloworld_HelloWorldJNI
 * Method:    getCPUModel
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_example_helloworld_HelloWorldJNI_getCPUModel
  (JNIEnv *env, jobject obj) {
    FILE *cpuinfo = fopen("/proc/cpuinfo", "r");
    char line[256];
    char model[256] = "Unknown";
    
    if (cpuinfo == NULL) {
        return (*env)->NewStringUTF(env, "Could not read CPU info");
    }
    
    while (fgets(line, sizeof(line), cpuinfo)) {
        if (strstr(line, "model name") || strstr(line, "Processor")) {
            char *p = strchr(line, ':');
            if (p) {
                p += 2; // Skip ": "
                strcpy(model, p);
                // Remove newline if present
                size_t len = strlen(model);
                if (len > 0 && model[len-1] == '\n') {
                    model[len-1] = '\0';
                }
                break;
            }
        }
    }
    
    fclose(cpuinfo);
    return (*env)->NewStringUTF(env, model);
}
