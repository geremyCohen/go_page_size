#ifndef _TCNATIVE_H_
#define _TCNATIVE_H_

#include <jni.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jstring JNICALL Java_org_apache_tomcat_jni_Library_getVersion
  (JNIEnv *, jclass);

JNIEXPORT jint JNICALL Java_org_apache_tomcat_jni_Library_initialize
  (JNIEnv *, jclass);

#ifdef __cplusplus
}
#endif

#endif /* _TCNATIVE_H_ */
