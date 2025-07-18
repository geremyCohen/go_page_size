#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "tcnative.h"

JNIEXPORT jstring JNICALL Java_org_apache_tomcat_jni_Library_getVersion
  (JNIEnv *env, jclass cls)
{
    return (*env)->NewStringUTF(env, "1.0.0");
}

JNIEXPORT jint JNICALL Java_org_apache_tomcat_jni_Library_initialize
  (JNIEnv *env, jclass cls)
{
    return 0;
}
