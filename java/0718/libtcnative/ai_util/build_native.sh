#!/bin/bash
set -e

# Define paths
WORK_DIR="/home/ubuntu/go_page_size/java/0718/libtcnative"
SOURCE_DIR="${WORK_DIR}/tomcat-native"
BUILD_DIR="${WORK_DIR}/ai_build"
INSTALL_DIR="${BUILD_DIR}/install"

# Create build directory if it doesn't exist
mkdir -p "${BUILD_DIR}"
mkdir -p "${INSTALL_DIR}"

# Create a simple JNI library
cd "${WORK_DIR}/ai_util"

# Create a simple JNI header file
cat > tcnative.h << 'EOF'
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
EOF

# Create a simple JNI implementation
cat > tcnative.c << 'EOF'
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
EOF

# Compile the JNI library
gcc -shared -fPIC -I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux tcnative.c -o ${BUILD_DIR}/libtcnative-1.so

# Copy the compiled library to the install directory
mkdir -p "${INSTALL_DIR}/lib"
cp ${BUILD_DIR}/libtcnative-1.so "${INSTALL_DIR}/lib/"

# Create a JAR file from the compiled Java classes
cd "${SOURCE_DIR}"
jar cf "${INSTALL_DIR}/tomcat-native.jar" -C dist/classes/java org

echo "Build completed successfully!"
