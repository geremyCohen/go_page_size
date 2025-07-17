#include <jni.h>
#include <sqlite3.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

JNIEXPORT jlong JNICALL Java_com_example_SQLiteDemo_openDatabase(JNIEnv *env, jclass cls, jstring dbPath) {
    printf("****** hello from custom sqlite\n"); fflush(stdout);
    
    const char *path = (*env)->GetStringUTFChars(env, dbPath, 0);
    sqlite3 *db;
    int rc = sqlite3_open(path, &db);
    (*env)->ReleaseStringUTFChars(env, dbPath, path);
    
    if (rc != SQLITE_OK) {
        return 0;
    }
    return (jlong)(uintptr_t)db;
}

JNIEXPORT void JNICALL Java_com_example_SQLiteDemo_closeDatabase(JNIEnv *env, jclass cls, jlong dbPtr) {
    sqlite3 *db = (sqlite3*)(uintptr_t)dbPtr;
    if (db) {
        sqlite3_close(db);
    }
}

JNIEXPORT jstring JNICALL Java_com_example_SQLiteDemo_getVersion(JNIEnv *env, jclass cls) {
    return (*env)->NewStringUTF(env, sqlite3_libversion());
}
